defmodule Gameplatform.Accounts.Schema.User do
  use Ecto.Schema

  schema "users" do
    field :phone_number, :string
    field :country_code, :string
    field(:created_at, :utc_datetime)
    field(:updated_at, :utc_datetime)
  end
end
