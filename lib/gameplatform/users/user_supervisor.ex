defmodule Gameplatform.Users.UserSupervisor do
  @moduledoc """
  This module is a supervisor process for the user process. It starts a user process whrn a user socker is initiated.
  """
  use DynamicSupervisor

  alias Gameplatform.Cache
  alias Gameplatform.Users.UserServer

  require Logger

  @process_id "user_process"

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec call_message(integer(), any()) :: :ok | any()
  def call_message(user_id, payload) do
    case get_child_pid(user_id) do
      {:ok, pid} ->
        GenServer.call(pid, payload)

      nil ->
        {:error, :reconnect_client}

      error ->
        error
    end
  end

  @spec start_user_process(integer(), String.t()) :: {:ok, pid()} | {:error, any()}
  def start_user_process(user_id, user_channel) do
    with nil <- get_child_pid(user_id),
         {:ok, pid} <- start_child(user_id, user_channel) do
      {:ok, pid}
    else
      {:ok, pid} ->
        GenServer.cast(pid, :initialise_login)
        {:ok, pid}

      {:error, error} ->
        Logger.error("Error in joining channel for user channel with error #{error}")
        {:error, "unknown error"}
    end
  end

  def get_proc_identifier(user_id), do: "#{@process_id}_#{user_id}"

  defp is_child_alive(pid), do: Process.alive?(pid)

  defp get_child_pid(user_id) do
    name = get_proc_identifier(user_id)

    case check_user_exists_in_registry(name) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, :user_does_not_exist} ->
        check_user_exists_in_redis(name)
    end
  end

  defp check_user_exists_in_registry(proc_name) do
    case Registry.lookup(Gameplatform.UserRegistry, proc_name) do
      [{pid, _}] ->
        {:ok, pid}

      [] ->
        error_msg = :user_does_not_exist
        {:error, error_msg}
    end
  end

  def check_user_exists_in_redis(name) do
    with {:ok, pid} when pid != nil <- Cache.get_value_from_cache(name),
         pid <- :erlang.list_to_pid(to_charlist(pid)),
         true <- is_child_alive(pid) do
      {:ok, pid}
    else
      {:ok, nil} ->
        nil

      false ->
        Cache.delete_value_from_cache(name)
        nil

      error ->
        error
    end
  end

  defp start_child(user_id, user_channel) do
    child_spec = %{
      id: UserServer,
      restart: :transient,
      shutdown: 5000,
      start: {UserServer, :start_link, [%{user_id: user_id, user_channel: user_channel}]},
      type: :worker
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}

      {:error, _} = error ->
        Logger.error(
          "Unable to start user_supervisor process for user #{user_id} with error - #{error}"
        )

        error
    end
  end
end
