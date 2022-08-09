defmodule Gameplatform.GameQueue.QueueServer do
  @moduledoc """
  Implemetation for any queue
  """
  use GenServer

  alias Gameplatform.GameQueue.GameQueue

  def start_link(args) do
    name = get_queue_registration_name(args)
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

  defp get_queue_registration_name(%{game_id: game_id, sku_code: sku_code} = _args) do
    "#{game_id}_#{sku_code}"
  end
end
