defmodule GameplatformWeb.MainAppChannel do
  use GameplatformWeb, :channel

  alias Gameplatform.UserSupervisor
  alias GameplatformWeb.Utils

  require Logger

  @channel_prefix "main_app:user:"

  @impl true
  def join(@channel_prefix <> user_id = uid, _payload, socket) do
    if authorized?(user_id, socket) do
      case UserSupervisor.start_children(user_id, uid) do
        :ok ->
          {:ok, socket}

        {:error, reason} ->
          {:error, %{reason: reason}}
      end
    else
      Logger.error("Error in joining channel for user - #{uid} with error unauthorized.")
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("main_app:game:join" = event, payload, socket) do
    user_id = socket.assigns.user_id

    case UserSupervisor.call_message(
           @channel_prefix <> to_string(user_id),
           {:game_join, payload, user_id}
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

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (main_app:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast(socket, "shout", payload)
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  defp authorized?(user_id, socket) do
    socket.assigns.user_id != nil && String.to_integer(user_id) === socket.assigns.user_id
  end
end
