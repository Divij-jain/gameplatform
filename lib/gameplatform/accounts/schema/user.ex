defmodule Gameplatform.Accounts.Schema.User do
  use Ecto.Schema

  alias Gameplatform.Accounts.Schema.UserProfile

  schema "users" do
    field :phone_number, :string
    field :country_code, :string
    timestamps(type: :utc_datetime_usec)

    has_one :user_profiles, UserProfile, foreign_key: :user_id
  end
end
