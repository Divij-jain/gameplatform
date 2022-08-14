defmodule Gameplatform.GameQueue.QueueServer do
  @moduledoc """
  Implemetation for any queue
  """
  use GenServer

  alias Gameplatform.GameQueue.Model.GameQueue
  alias Gameplatform.GameSupervisor

  # The polling is fixed for the event to happen at exact time due to handle_continue
  @polling_time 1000

  def start_link(args) do
    name = Map.get(args, :name)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @spec init(map()) ::
          {:ok, %{queue: Gameplatform.GameQueue.Model.GameQueue.t()}, {:continue, :poll_users}}
  def init(init_arg) do
    game_queue = GameQueue.new(init_arg)
    {:ok, %{queue: game_queue}, {:continue, :poll_users}}
  end

  def handle_continue(:poll_users, state) do
    poll_users(state)
  end

  def handle_info(:poll_users, state) do
    {:noreply, state, {:continue, :poll_users}}
  end

  def handle_call({:add_user, user_id, amount}, _from, %{queue: %GameQueue{} = queue} = state) do
    if Decimal.eq?(queue.amount, amount) do
      new_queue = GameQueue.add_user_to_queue(queue, user_id)
      new_state = update_state(state, new_queue)
      reply = {:ok, :user_added}
      {:reply, reply, new_state}
    else
      reply = {:error, :invalid_amount}
      {:reply, reply, state}
    end
  end

  defp update_state(state, new_queue) do
    %{state | queue: new_queue}
  end


  defp poll_users(%{queue: %GameQueue{} = queue} = state) do
    required_num_users = queue.req_num_players

    if length(queue.users) >= required_num_users do
      %{new_queue: new_queue, users: users} = GameQueue.get_users_from_queue(queue)
      add_users_to_game(queue, users)
      new_state = update_state(state, new_queue)
      {:noreply, new_state, {:continue, :poll_users}}
    else
      schedule_polling()
      {:noreply, state}
    end
  end

  defp schedule_polling do
    Process.send_after(self(), :poll_users, @polling_time)
  end

  defp add_users_to_game(%GameQueue{} = queue, users) do
    # later add this block under Task.start/1
    args =
      queue
      |> Map.take([:game_id, :app_id, :sku_code, :amount, :req_num_players])
      |> Map.put(:players, users)

    GameSupervisor.start_game(args)
  end
end
