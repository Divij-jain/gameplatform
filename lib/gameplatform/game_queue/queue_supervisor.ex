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

  # fetches children for the supervisor

  def get_all_children() do
    games_with_sku = get_all_queues()
    build_child_with_specs(games_with_sku)
  end

  # To get all the games and their respective Skus

  defp get_all_queues() do
    Repository.get_sku_list_for_all_games()
  end

  # creating all children specifications

  defp build_child_with_specs(games_with_sku) do
    for %Game{game_skus: game_skus} = game_with_sku <- games_with_sku do
      for %GameSku{} = game_sku <- game_skus do
        game_id = game_with_sku.id
        sku_code = game_sku.sku_code

        Supervisor.child_spec(
          {
            QueueServer,
            %{
              game_id: game_id,
              sku_code: sku_code,
              amount: game_sku.amount,
              name: get_queue_registration_name(game_id, sku_code)
            }
          },
          id: {QueueServer, {game_with_sku.id, game_sku.sku_code}}
        )
      end
    end
    |> List.flatten()
  end

  defp get_queue_registration_name(game_id, sku_code) do
    "game_queue_#{game_id}_#{sku_code}"
    |> String.to_atom()
  end

  def add_user_to_queue(args) do
    %{user_id: user_id, game_id: game_id, sku_code: sku_code, amount: amount} = args
    name = get_queue_registration_name(game_id, sku_code)
    call_message(name, {:add_user, user_id, amount})
  end

  def call_message(name, message) do
    case check_queue_exists(name) do
      {:ok, pid} ->
        GenServer.call(pid, message)

      {:error, _} = error ->
        error
    end
  end

  defp send_message(name, message) do
    case check_queue_exists(name) do
      {:ok, pid} ->
        GenServer.cast(pid, message)

      {:error, _} = error ->
        error
    end
  end

  defp check_queue_exists(name) do
    case Process.whereis(name) do
      nil ->
        {:error, :no_queue_exists}

      pid ->
        {:ok, pid}
    end
  end
end
