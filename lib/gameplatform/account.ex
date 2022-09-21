defmodule Gameplatform.Account do
  alias Gameplatform.Accounts.Repository, as: Repo
  alias Gameplatform.Accounts.Schema.{User, UserWalletTx}
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

  @spec create_new_user(map()) :: {:ok, User.t()} | {:error, any()}
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

  @spec get_complete_user(Ecto.UUID.t()) :: {:ok, User.t() | nil}
  def get_complete_user(user_id) do
    Repo.get_user(user_id)
  end

  @type money_update_to_wallet_params :: %{
          amount: Decimal.t(),
          user_wallet_id: Ecto.UUID.t(),
          meta_tx_id: Ecto.UUID.t(),
          tx_type: :credit | :debit
        }

  @spec add_money_to_wallet(money_update_to_wallet_params) ::
          {:ok, UserWalletTx.t()} | {:error, map()}
  def add_money_to_wallet(attrs) do
    Repo.create_wallet_tx(attrs)
  end

  @moduledoc """
  Later turn this function into Repo.transaction
  """

  @spec deduct_money_from_wallet(money_update_to_wallet_params) :: {:ok, UserWalletTx.t()}
  def deduct_money_from_wallet(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:deduct_money, fn _repo, _ ->
      with {:ok, _wallet} <- Repo.get_wallet(attrs.user_wallet_id),
           {:ok, amount} <- Repo.get_wallet_balance(attrs.user_wallet_id),
           false <- Decimal.lt?(amount, Decimal.abs(attrs.amount)) do
        Repo.create_wallet_tx(attrs)
      else
        true ->
          {:error, :not_enogh_balance}

        error ->
          error
      end
    end)
    |> Gameplatform.Repo.transaction()
    |> case do
      {:ok, %{deduct_money: tx} = _changes} ->
        {:ok, tx}

      {:error, _, error, _} = _error ->
        {:error, error}
    end
  end

  # this function is already under a transaction
  defp create_user_wallets(attrs) do
    with {:ok, user_wallet_1} <-
           Repo.create_user_wallet(Map.put(attrs, :wallet_type, "user_wallet")),
         {:ok, user_wallet_2} <-
           Repo.create_user_wallet(Map.put(attrs, :wallet_type, "promotional_wallet")) do
      {:ok, %{wallet_1: user_wallet_1, wallet_2: user_wallet_2}}
    end
  end

  defp check_existing_user(attrs) do
    Repo.get_user_by_phone_number(attrs.phone_number)
  end
end
