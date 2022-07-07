defmodule Gameplatform.Accounts.Schema.UserWallet do
  use Ecto.Schema

  alias Gameplatform.Accounts.Schema.{UserProfile, UserWalletTx}

  schema "user_wallets" do
    field :wallet_type, :string
    timestamps(type: :utc_datetime_usec)

    belongs_to :user_profile, UserProfile
    has_many :user_wallet_txs, UserWalletTx, foreign_key: :user_wallet_id
  end
end
