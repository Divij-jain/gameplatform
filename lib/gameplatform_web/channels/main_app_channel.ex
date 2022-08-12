defmodule GameplatformWeb.MainAppChannel do
  use GameplatformWeb, :channel

  alias Gameplatform.UserSupervisor

  require Logger

  @impl true
  def join("main_app:user:" <> user_id = uid, _payload, socket) do
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

  def broadcast_message_to_user(topic, event, msg), do: broadcast!(topic, event, msg)

  # Add authorization logic here as required.
  defp authorized?(user_id, socket) do
    socket.assigns.user_id != nil && String.to_integer(user_id) === socket.assigns.user_id
  end
end
