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
    {:ok, %{queue: game_queue}}
  end

  def handle_info(:timeout, state) do
    new_state = state
    {:noreply, new_state}
  end

  def handle_call({:add_user, user_id, amount}, _from, %{queue: queue} = state) do
    queue_amount = GameQueue.get_queue_amount(queue)
    IO.inspect([queue_amount, amount])

    if Decimal.eq?(queue_amount, amount) do
      new_queue = GameQueue.add_to_queue(queue, user_id)
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
end
