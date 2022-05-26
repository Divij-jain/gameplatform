defmodule Gameplatform.Account do
  alias Gameplatform.Accounts.Changesets.{User}
  alias Gameplatform.Accounts.Repository, as: Repo

  def register_user(attrs) do
    attrs
    |> User.build()
    |> Repo.insert()
  end
end
