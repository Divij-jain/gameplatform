defmodule Gameplatform.Accounts.Queries do
  @moduledoc """
  for db queries
  """

  import Ecto.Query

  alias Gameplatform.Accounts.Schema.{User, UserProfile, UserWallet, UserWalletTx}

  def user_query(user_id) do
    User
    |> match_user_id(user_id)
    |> build_basic_query()
  end

  def build_basic_query(query) do
    from(user in query,
      left_join: profile in UserProfile,
      on: user.id == profile.user_id,
      left_join: wallet in UserWallet,
      on: profile.id == wallet.user_profile_id,
      left_join: tx in UserWalletTx,
      on: wallet.id == tx.user_wallet_id,
      preload: [
        user_profiles: {profile, user_wallets: {wallet, user_wallet_txs: tx}}
      ]
    )
  end

  def match_user_id(query, user_id) do
    from(user in query,
      where: user.id == ^user_id
    )
  end

  def match_user_wallet_id(query, user_wallet_id) do
    from(user_wallet_tx in query,
      where: user_wallet_tx.user_wallet_id == ^user_wallet_id
    )
  end
end
