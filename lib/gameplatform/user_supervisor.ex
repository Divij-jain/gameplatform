defmodule Gameplatform.UserSupervisor do
  @moduledoc """
  This module is a supervisor process for the user process. It starts a user process whrn a user socker is initiated.
  """

  use DynamicSupervisor

  alias Gameplatform.Cache
  alias Gameplatform.UserWorker

  require Logger

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_children(user_id, user_channel) do
    with {:ok, process_pid} when process_pid != nil <- Cache.get_value_from_cache(user_channel),
         true <- Process.alive?(:erlang.list_to_pid(to_charlist(process_pid))) do
      GenServer.cast(:erlang.list_to_pid(to_charlist(process_pid)), :initialise_login)
      :ok
    else
      {:ok, nil} ->
        start_child(user_id, user_channel)
        :ok

      false ->
        start_child(user_id, user_channel)
        :ok

      err ->
        Logger.error("Error in joining channel for user - #{user_channel} with error #{err}")
        {:error, "unknown error"}
    end
  end

  defp start_child(user_id, user_channel) do
    child_spec = %{
      id: UserWorker,
      restart: :transient,
      shutdown: 5000,
      start: {UserWorker, :start_link, [[user_id, user_channel]]},
      type: :worker
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, _pid} ->
        :ok

      error ->
        Logger.error(
          "Unable to start user_supervisor process for user #{user_id} with error - #{error}"
        )

        :error
    end
  end
end