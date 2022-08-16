defmodule Gameplatform.Accounts.Schema.UserWalletTx do
  use Ecto.Schema

  alias Gameplatform.Accounts.Schema.UserWallet

  schema "user_wallet_txs" do
    field :meta_tx_id, Ecto.UUID
    field :amount, :decimal
    field :tx_type, Ecto.Enum, values: [:debit, :credit]
    timestamps(type: :utc_datetime_usec)

    belongs_to :user_wallet, UserWallet
  end
end
