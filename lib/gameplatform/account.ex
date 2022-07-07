defmodule Gameplatform.Account do
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

  def get_complete_user(user_id) do
    Repo.get_user(user_id)
  end

  def create_new_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:create_user, fn _repo, _ ->
      Repo.create_new_user(attrs)
    end)
    |> Ecto.Multi.run(:create_user_profile, fn _repo, %{create_user: user} = _changes ->
      attrs = Map.put(attrs, :user_id, user.id)
      Repo.create_user_profile(attrs)
    end)
    |> Ecto.Multi.run(:create_user_wallets, fn _repo,
                                               %{create_user_profile: user_profile} = _changes ->
      attrs = Map.put(attrs, :user_profile_id, user_profile.id)
      create_user_wallets(attrs)
    end)
    |> Gameplatform.Repo.transaction()
    |> case do
      {:ok, %{create_user: user} = _changes} ->
        {:ok, user}

      {:error, _, changeset, _} = _error ->
        {:error, ChangesetErrorTranslator.translate_error(changeset)}
    end
  end

  defp create_user_wallets(attrs) do
    with {:ok, user_wallet_1} <-
           Repo.create_user_wallet(Map.put(attrs, :wallet_type, "winnings")),
         {:ok, user_wallet_2} <-
           Repo.create_user_wallet(Map.put(attrs, :wallet_type, "deposits")) do
      {:ok, %{wallet_1: user_wallet_1, wallet_2: user_wallet_2}}
    end
  end

  defp handle_result({:ok, user}), do: {:ok, user}

  defp handle_result({:error, result}),
    do: {:error, ChangesetErrorTranslator.translate_error(result)}
end
