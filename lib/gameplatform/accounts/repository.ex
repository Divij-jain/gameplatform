defmodule Gameplatform.Accounts.Repository do
  alias Gameplatform.Repo
  alias Gameplatform.Accounts.Changesets
  alias Gameplatform.Accounts.Schema.User
  alias Gameplatform.Accounts.Queries
  alias Gameplatform.Ecto.ChangesetErrorTranslator

  def get_user_by_phone_number(phone_number) do
    Repo.get_by(User, phone_number: phone_number)
  end

  def get_user(user_id) do
    user_id
    |> Queries.user_query()
    |> Repo.one()
    |> handle_result()
  end

  def create_new_user(attrs) do
    attrs
    |> Changesets.User.build()
    |> Repo.insert()
  end

  def create_user_profile(attrs) do
    attrs
    |> Changesets.UserProfile.build()
    |> Repo.insert()
  end

  def create_user_wallet(attrs) do
    attrs
    |> Changesets.UserWallet.build()
    |> Repo.insert()
  end

  defp handle_result({:ok, result}), do: {:ok, result}

  defp handle_result({:error, result}),
    do: {:error, ChangesetErrorTranslator.translate_error(result)}

  defp handle_result(result), do: {:ok, result}
end
