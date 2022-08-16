defmodule Gameplatform.Runtime.GameSupervisor do
  @moduledoc """
    This module is for implementation of game supervisor that supervises all type of game.
  """
  use DynamicSupervisor

  alias Gameplatform.Runtime.GameServer

  require Logger

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(args) do
    child_spec = %{
      id: GameServer,
      restart: :transient,
      shutdown: 5000,
      start: {GameServer, :start_link, [[args]]},
      type: :worker
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, _pid} ->
        :ok

      error ->
        IO.inspect(error)
        Logger.error("Unable to start game server process for game with error ")
        error
    end
  end
end
