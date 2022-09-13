defmodule Gameplatform.Account do
  alias Gameplatform.Accounts.Repository, as: Repo
  alias Gameplatform.Accounts.Schema.User
  alias Gameplatform.ApiSpec.Schema.SubmitOtpRequest
  alias Gameplatform.Ecto.ChangesetErrorTranslator

  @spec get_current_user(SubmitOtpRequest.t()) :: {:ok, User.t()} | {:error, map()}
  def get_current_user(attrs) do
    case check_existing_user(attrs) do
      %_{} = user ->
        {:ok, user}

      nil ->
        create_new_user(attrs)
    end
  end

  def check_existing_user(attrs) do
    Repo.get_user_by_phone_number(attrs.phone_number)
  end

  def get_complete_user(user_id) do
    Repo.get_user(user_id)
  end

  def create_new_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:create_user, fn _repo, _ ->
      Repo.create_new_user(attrs)
    end)
    |> Ecto.Multi.run(:create_user_profile, fn _repo, %{create_user: user} = _changes ->
      attrs = Map.put(attrs, :user_id, user.id)
      Repo.create_user_profile(attrs)
    end)
    |> Ecto.Multi.run(:create_user_wallets, fn _repo,
                                               %{create_user_profile: user_profile} = _changes ->
      attrs = Map.put(attrs, :user_profile_id, user_profile.id)
      create_user_wallets(attrs)
    end)
    |> Gameplatform.Repo.transaction()
    |> case do
      {:ok, %{create_user: user} = _changes} ->
        {:ok, user}

      {:error, _, changeset, _} = _error ->
        {:error, ChangesetErrorTranslator.translate_error(changeset)}
    end
  end

  def add_money_to_wallet(attrs) do
    Repo.create_wallet_tx(attrs)
  end

  @moduledoc """
  Later turn this function into Repo.transaction
  """
  def deduct_money_from_wallet(attrs) do
    with amount <- Repo.get_wallet_balance(attrs.user_wallet_id),
         new_amount <- Decimal.add(amount, attrs.amount),
         false <- Decimal.negative?(new_amount) do
      Repo.create_wallet_tx(attrs)
    else
      true ->
        {:error, :not_enogh_balance}
    end
  end

  defp create_user_wallets(attrs) do
    with {:ok, user_wallet_1} <-
           Repo.create_user_wallet(Map.put(attrs, :wallet_type, "user_wallet")),
         {:ok, user_wallet_2} <-
           Repo.create_user_wallet(Map.put(attrs, :wallet_type, "promotional_wallet")) do
      {:ok, %{wallet_1: user_wallet_1, wallet_2: user_wallet_2}}
    end
  end
end
