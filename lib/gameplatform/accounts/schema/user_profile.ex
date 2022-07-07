defmodule Gameplatform.Accounts.Schema.UserProfile do
  use Ecto.Schema

  alias Gameplatform.Accounts.Schema.{User, UserWallet}

  schema "user_profiles" do
    field :phone_number, :string
    field :email, :string
    field :first_name, :string
    field :second_name, :string
    field :kyc_status, :boolean
    timestamps(type: :utc_datetime_usec)

    has_many :user_wallets, UserWallet, foreign_key: :user_profile_id
    belongs_to :user, User
  end
end
