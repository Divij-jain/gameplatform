defmodule GameplatformWeb.UserSocket do
  @moduledoc """
  This module implements user web socket connection for the main application.
  """

  use Phoenix.Socket

  channel "main_app:user:*", GameplatformWeb.MainAppChannel

  alias Gameplatform.Auth.Token.TokenClient

  @impl true
  def connect(%{"token" => token} = params, socket, _connect_info) do
    IO.inspect(params)

    case TokenClient.get_user_id_by_jwt_token(Jason.decode!(token)) do
      nil ->
        IO.inspect("here")
        :error

      user_id ->
        {:ok, assign(socket, :user_id, user_id)}
    end
  end

  @impl true
  def id(_socket), do: nil
end
