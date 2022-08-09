defmodule Gameplatform.GameQueue.QueueSupervisor do
  @moduledoc """
    This module is for implementation of queue supervisor that supervises any queue for game joining.
  """
  use Supervisor

  alias Gameplatform.Games.Repository
  alias Gameplatform.Games.Schema.Game
  alias Gameplatform.GameQueue.QueueServer

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = get_all_children()

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  fetches children for the supervisor
  """
  def get_all_children() do
    get_all_queues()
    |> Enum.map(fn game ->
      child_opts = get_child_opts(game)
      {QueueServer, child_opts}
    end)
  end

  @doc """
  To get all the games and their respective Skus
  """
  def get_all_queues() do
    Repository.get_sku_list_for_all_games()
  end

  @doc """
  creating a keyword to send to queue server for its intialization
  """
  def get_child_opts(%Game{} = game) do
    %{
      game_id: game.id,
      sku_code: game.sku.sku_code,
      amount: game.sku.sku_amount
    }
  end
end
