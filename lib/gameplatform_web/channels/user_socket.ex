defmodule GameplatformWeb.UserSocket do
  @moduledoc """
  This module implements user web socket connection for the main application.
  """

  use Phoenix.Socket

  channel "main_app:user:*", GameplatformWeb.MainAppChannel

  alias Gameplatform.Auth.Token.TokenClient

  @socket_id "user_socket"

  @impl true
  def connect(%{"token" => token} = _params, socket, _connect_info) do
    token = Jason.decode!(token)

    case verify_token(token) do
      {:ok, user_id} ->
        socket = assign(socket, :user_id, user_id)
        {:ok, socket}

      nil ->
        :error
    end
  end

  @impl true
  def id(%{assigns: %{user_id: user_id}} = _socket), do: "#{@socket_id}_#{user_id}"

  defp verify_token(token), do: TokenClient.get_user_id_by_jwt_token(token)
end
