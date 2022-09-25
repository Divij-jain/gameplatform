defmodule GameplatformWeb.UserSocket do
  @moduledoc """
  This module implements user web socket connection for the main application.
  """

  use Phoenix.Socket

  require Logger

  channel "main_app:user:*", GameplatformWeb.MainAppChannel

  alias Gameplatform.Auth.Token.TokenClient
  alias GameplatformWeb.ApiToConfig

  @impl true
  def connect(%{"token" => token} = _params, socket, _connect_info) do
    token = get_decoded_value(token)

    case verify_token(token) do
      {:ok, user_id} ->
        socket = assign(socket, :user_id, user_id)
        {:ok, socket}

      nil ->
        :error
    end
  end

  def connect(_, _socket, _) do
    Logger.error("#{__MODULE__} connect error missing params")
    :error
  end

  @impl true
  def id(%{assigns: %{user_id: user_id}} = _socket) do
    socket_id = ApiToConfig.socket_id()
    socket_id <> user_id
  end

  defp verify_token(token), do: TokenClient.get_user_id_by_jwt_token(token)

  def get_decoded_value(value) do
    case Jason.decode(value) do
      {:ok, value} ->
        value

      {:error, %Jason.DecodeError{}} ->
        value
    end
  end
end
