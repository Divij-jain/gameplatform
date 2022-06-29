defmodule Gameplatform.Account do
  alias Gameplatform.Accounts.Changesets.{User}
  alias Gameplatform.Accounts.Repository, as: Repo
  alias Gameplatform.Ecto.ChangesetErrorTranslator

  def get_current_user(attrs) do
    case check_existing_user(attrs) do
      %_{} = user ->
        {:ok, user}

      nil ->
        create_new_user(attrs)
    end
  end

  def check_existing_user(attrs) do
    Repo.get_user_by_phone_number(attrs.phone_number)
  end

  def create_new_user(attrs) do
    attrs
    |> User.build()
    |> Repo.insert()
    |> handle_result()
  end

  defp handle_result({:ok, user}), do: {:ok, user}

  defp handle_result({:error, result}),
    do: {:error, ChangesetErrorTranslator.translate_error(result)}
end
