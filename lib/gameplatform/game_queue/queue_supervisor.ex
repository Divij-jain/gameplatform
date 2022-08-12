defmodule Gameplatform.GameQueue.QueueSupervisor do
  @moduledoc """
    This module is for implementation of queue supervisor that supervises any queue for game joining.
  """
  use Supervisor

  alias Gameplatform.Games.Repository
  alias Gameplatform.Games.Schema.{Game, GameSku}
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
    games_with_sku = get_all_queues()
    build_child_with_specs(games_with_sku)
  end

  @doc """
  To get all the games and their respective Skus
  """
  def get_all_queues() do
    Repository.get_sku_list_for_all_games()
  end

  @doc """
  creating all children specifications
  """

  def build_child_with_specs(games_with_sku) do
    for %Game{game_skus: game_skus} = game_with_sku <- games_with_sku do
      for %GameSku{} = game_sku <- game_skus do
        Supervisor.child_spec(
          {
            QueueServer,
            %{
              game_id: game_with_sku.id,
              sku_code: game_sku.sku_code,
              amount: game_sku.amount
            }
          },
          id: {QueueServer, {game_with_sku.id, game_sku.sku_code}}
        )
      end
    end
    |> List.flatten()
  end
end