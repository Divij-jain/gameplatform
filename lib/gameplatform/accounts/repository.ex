defmodule Gameplatform.Accounts.Repository do
  alias Gameplatform.Repo

  def insert(changeset) do
    Repo.insert(changeset)
  end
end
