defmodule Gameplatform.Auth.Token.TokenClient do
  alias Gameplatform.Auth.Token

  def create_new_token(user) do
    claims = %{"user_id" => user.id}
    {:ok, token, _claims} = Token.generate_and_sign(claims)
    token
  end

  def get_user_id_by_jwt_token(token) do
    # {:ok, claims} = Token.verify_and_validate(token)
    case Token.verify_and_validate(token) do
      {:ok, claims} ->
        Map.get(claims, "user_id")

      _ ->
        nil
    end
  end
end
