defmodule Gameplatform.GameQueue.Model.GameQueue do
  @moduledoc """
  Defines the structure of game queue
  """

  alias __MODULE__

  defstruct [:users, :game_id, :sku_code, :amount]

  @type t :: %__MODULE__{
          users: list(),
          game_id: String.t(),
          sku_code: String.t(),
          amount: number()
        }

  @spec new(map()) :: GameQueue.t()
  def new(args) do
    %{
      game_id: game_id,
      sku_code: sku_code,
      amount: sku_amount
    } = args

    %__MODULE__{
      users: [],
      game_id: game_id,
      sku_code: sku_code,
      amount: sku_amount
    }
  end

  @spec get_queue_amount(queue :: GameQueue.t()) :: Decimal.t()
  def get_queue_amount(queue), do: queue.amount

  @spec add_user_to_queue(queue :: GameQueue.t(), any()) :: GameQueue.t()
  def add_user_to_queue(queue, user_id) do
    Map.update(queue, :users, [], fn existing_users ->
      existing_users ++ [user_id]
    end)
  end

  @spec get_from_queue(queue :: GameQueue.t(), number()) :: map()
  def get_from_queue(queue, num_of_users) do
    {users, new_users} = Enum.split(queue.users, num_of_users)
    new_queue = %{queue | users: new_users}
    %{new_queue: new_queue, users: users}
  end
end
