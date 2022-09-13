defmodule Gameplatform.Auth.Token.TokenClient do
  @moduledoc """
  client for interacting with JokenClient
  """

  alias Gameplatform.Auth.Token
  alias Gameplatform.Accounts.Schema.User

  require Logger

  @doc """
  Generates a jwt token with user details
  """
  @spec create_new_token(User.t()) ::
          {:ok, Joken.bearer_token()} | {:error, code :: number(), reason :: String.t()}
  def create_new_token(user = %User{}) do
    claims = %{"user_id" => user.id}

    case Token.generate_and_sign(claims) do
      {:ok, token, _claims} ->
        {:ok, token}

      {:error, _} = error ->
        Logger.error(error)

        {:error, 500, "Internal Server Error"}
    end
  end

  @spec get_user_id_by_jwt_token(Joken.bearer_token()) :: {:ok, id :: number()} | nil
  def get_user_id_by_jwt_token(token) do
    case Token.verify_and_validate(token) do
      {:ok, claims} ->
        {:ok, Map.get(claims, "user_id")}

      {:error, _} = error ->
        Logger.error(error)
        nil
    end
  end
end
