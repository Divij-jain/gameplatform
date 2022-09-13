defmodule Gameplatform.Accounts.Schema.UserWallet do
  use Ecto.Schema

  alias Gameplatform.Accounts.Schema.{UserProfile, UserWalletTx}

  @type t() :: %__MODULE__{
          id: number(),
          wallet_type: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          user_profile_id: number(),
          user_wallet_txs: list(UserWalletTx.t())
        }

  schema "user_wallets" do
    field :wallet_type, :string
    timestamps(type: :utc_datetime_usec)

    belongs_to :user_profile, UserProfile
    has_many :user_wallet_txs, UserWalletTx, foreign_key: :user_wallet_id
  end
end
