defmodule Gameplatform.Accounts.Repository do
  @moduledoc """
  Repository module for the platform.
  """
  alias Gameplatform.Repo
  alias Gameplatform.Accounts.Changesets
  alias Gameplatform.Accounts.Schema.{User, UserWallet, UserWalletTx, ReferralCode}
  alias Gameplatform.Accounts.Queries
  alias Gameplatform.Ecto.ChangesetErrorTranslator

  @spec get_user_by_phone_number(String.t()) :: User.t() | nil
  def get_user_by_phone_number(phone_number) do
    Repo.get_by(User, phone_number: phone_number)
  end

  @spec get_user(Ecto.UUID.t()) :: {:ok, User.t() | nil}
  def get_user(user_id) do
    user_id
    |> Queries.user_query()
    |> Repo.one()
    |> handle_result()
  end

  @spec get_wallet_balance(Ecto.UUID.t()) :: {:ok, Decimal.t()}
  def get_wallet_balance(wallet_id) do
    UserWalletTx
    |> Queries.match_user_wallet_id(wallet_id)
    |> Repo.aggregate(:sum, :amount)
    |> case do
      nil ->
        {:ok, Decimal.new(0)}

      balance ->
        {:ok, balance}
    end
  end

  @spec get_wallet(wallet_id :: Ecto.UUID.t()) ::
          {:ok, UserWallet.t()} | {:error, :does_not_exisit}
  def get_wallet(wallet_id) do
    case Repo.get(UserWallet, wallet_id) do
      nil ->
        {:error, :does_not_exisit}

      wallet ->
        {:ok, wallet}
    end
  end

  @spec get_referral_code_by_profile_id(profile_id :: Ecto.UUID.t()) :: ReferralCode.t() | nil
  def get_referral_code_by_profile_id(profile_id) do
    Repo.get_by(ReferralCode, user_profile_id: profile_id)
  end

  def create_new_user(attrs) do
    attrs
    |> Changesets.User.build()
    |> Repo.insert()
  end

  def create_user_profile(attrs) do
    attrs
    |> Changesets.UserProfile.build()
    |> Repo.insert()
  end

  def create_user_wallet(attrs) do
    attrs
    |> Changesets.UserWallet.build()
    |> Repo.insert()
  end

  @spec create_wallet_tx(map()) :: {:ok, UserWalletTx.t()} | {:error, any()}
  def create_wallet_tx(attrs) do
    attrs
    |> Changesets.UserWalletTx.build()
    |> Repo.insert()
    |> handle_result()
  end

  @spec create_referral_code(map()) :: {:ok, ReferralCode.t()} | {:error, any()}
  def create_referral_code(attrs) do
    attrs
    |> Changesets.ReferralCode.build()
    |> Repo.insert()
    |> handle_result()
  end

  defp handle_result({:ok, result}), do: {:ok, result}

  defp handle_result({:error, result}),
    do: {:error, ChangesetErrorTranslator.translate_error(result)}

  defp handle_result(result), do: {:ok, result}
end
