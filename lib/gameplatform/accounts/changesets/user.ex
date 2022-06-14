defmodule Gameplatform.Accounts.Changesets.User do
  import Ecto.Changeset

  alias Gameplatform.Accounts.Schema.User

  def build(user \\ %User{}, attrs) do
    user
    |> cast(attrs, [:phone_number, :country_code])
    |> validate_required([:phone_number, :country_code])
  end
end
