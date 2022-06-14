defmodule Gameplatform.Accounts.Repository do
  alias Gameplatform.Repo
  alias Gameplatform.Accounts.Schema.User

  def insert(changeset) do
    Repo.insert(changeset)
  end

  def get_user_by_phone_number(phone_number) do
    Repo.get_by(User, phone_number: phone_number)
  end
end
