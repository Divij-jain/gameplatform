defmodule Gameplatform.Accounts.Changesets.User do
  import Ecto.Changeset

  alias Gameplatform.Accounts.Schema.User

  def build(user \\ %User{}, attrs) do
    user
    |> cast(attrs, [:mobile_number, :country_code])
    |> validate_required([:mobile_number, :country_code])
  end
end
