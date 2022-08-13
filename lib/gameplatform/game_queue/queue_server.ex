defmodule Gameplatform.GameQueue.QueueServer do
  @moduledoc """
  Implemetation for any queue
  """
  use GenServer

  alias Gameplatform.GameQueue.Model.GameQueue

  def start_link(args) do
    name = Map.get(args, :name)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def init(init_arg) do
    game_queue = GameQueue.new(init_arg)
    {:ok, %{queue: game_queue}, {:continue, :poll_users}}
  end

  def handle_continue(:poll_users, state) do
    newstate = poll_users(state)
    schedule_polling()
    IO.inspect(state.queue.users, label: "hi")
    {:noreply, newstate}
  end

  def handle_info(:poll_users, state) do
    {:noreply, state, {:continue, :poll_users}}
  end

  def handle_call({:add_user, user_id, amount}, _from, %{queue: queue} = state) do
    queue_amount = GameQueue.get_queue_amount(queue)

    if Decimal.eq?(queue_amount, amount) do
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

  defp poll_users(%{queue: queue} = state) do
    response = GameQueue.get_from_queue(queue, 1)
    %{new_queue: new_queue, users: users} = response
    IO.inspect(users)
    update_state(state, new_queue)
  end

  def schedule_polling do
    Process.send_after(self(), :poll_users, 3_000)
  end
end
