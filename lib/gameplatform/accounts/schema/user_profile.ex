defmodule Gameplatform.Accounts.Schema.UserProfile do
  use Gameplatform.Schema

  @moduledoc false

  alias Gameplatform.Accounts.Schema.{User, UserWallet}

  @type t() :: %__MODULE__{
          id: Ecto.UUID.t(),
          phone_number: String.t(),
          email: String.t(),
          first_name: String.t(),
          second_name: String.t(),
          gender: String.t(),
          image: String.t(),
          kyc_status: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          user_id: Ecto.UUID.t(),
          user_wallets: list(UserWallet.t())
        }

  schema "user_profiles" do
    field :phone_number, :string
    field :email, :string
    field :first_name, :string
    field :second_name, :string
    field :gender, :string
    field :image, :string
    field :kyc_status, :boolean
    timestamps(type: :utc_datetime_usec)

    has_many :user_wallets, UserWallet, foreign_key: :user_profile_id
    belongs_to :user, User
  end
end
