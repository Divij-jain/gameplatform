defmodule Gameplatform.Accounts.Schema.UserWalletTx do
  use Ecto.Schema

  alias Gameplatform.Accounts.Schema.UserWallet

  @type t :: %__MODULE__{
          id: number(),
          meta_tx_id: Ecto.UUID.t(),
          amount: Decimal.t(),
          tx_type: atom(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          user_wallet_id: number()
        }

  schema "user_wallet_txs" do
    field :meta_tx_id, Ecto.UUID
    field :amount, :decimal
    field :tx_type, Ecto.Enum, values: [:debit, :credit]
    timestamps(type: :utc_datetime_usec)

    belongs_to :user_wallet, UserWallet
  end
end
