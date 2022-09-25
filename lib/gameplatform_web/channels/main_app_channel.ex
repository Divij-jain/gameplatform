defmodule GameplatformWeb.MainAppChannel do
  @moduledoc false

  use GameplatformWeb, :channel

  alias Gameplatform.Users.UserSupervisor
  alias GameplatformWeb.Utils

  require Logger

  @channel_prefix GameplatformWeb.ApiToConfig.channel_prefix()

  @doc """
  This function defines channel joining
  """
  @impl true
  def join(@channel_prefix <> user_id = uid, _payload, socket) do
    if authorized?(user_id, socket) do
      case UserSupervisor.start_user_process(user_id, uid) do
        {:ok, _} ->
          {:ok, socket}

        {:error, reason} ->
          {:error, %{reason: reason}}
      end
    else
      Logger.error("Error in joining channel for user - #{uid} with error unauthorized.")
      {:error, %{reason: "unauthorized"}}
    end
  end

  # refactoring needed in below since no need of broadcast where we could have easily replied to the message.
  @impl true
  def handle_in("main_app:game:join" = event, payload, socket) do
    user_id = socket.assigns.user_id

    case UserSupervisor.call_message(
           user_id,
           {:game_join, payload}
         ) do
      {:error, :reconnect_client} ->
        broadcast!(socket, "main_app:reload_client", %{})
        {:noreply, socket}

      {:ok, {reply, message}} ->
        broadcast!(socket, event, Utils.make_success_response(reply, message))
        {:noreply, socket}

      {:error, reason} ->
        broadcast!(socket, event, Utils.make_error_response(reason, %{}))
        {:noreply, socket}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("pong", _payload, socket) do
    {:noreply, socket}
  end

  def handle_in("stop", _payload, socket) do
    {:stop, :shutdown, {:ok, %{msg: "shutting down"}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (main_app:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast(socket, "shout", payload)
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  defp authorized?(user_id, socket) do
    socket_user_id = Map.get(socket.assigns, :user_id)
    socket_user_id != nil && user_id == socket_user_id
  end
end
