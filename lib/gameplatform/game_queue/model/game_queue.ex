defmodule Gameplatform.GameQueue.Model.GameQueue do
  @moduledoc """
  Defines the structure of game queue
  """

  alias __MODULE__

  defstruct [:users, :game_id, :app_id, :sku_code, :amount, :req_num_players]

  @type t() :: %__MODULE__{
          users: list(),
          game_id: String.t(),
          app_id: String.t(),
          sku_code: String.t(),
          amount: number(),
          req_num_players: number()
        }

  @spec new(map()) :: GameQueue.t()
  def new(args) do
    %{
      game_id: game_id,
      app_id: app_id,
      sku_code: sku_code,
      amount: sku_amount,
      num_players: num
    } = args

    %__MODULE__{
      users: [],
      game_id: game_id,
      app_id: app_id,
      sku_code: sku_code,
      amount: sku_amount,
      req_num_players: num
    }
  end

  @spec get_req_num_of_users(queue :: GameQueue.t()) :: number()
  def get_req_num_of_users(queue), do: queue.req_num_players

  @spec add_user_to_queue(queue :: GameQueue.t(), any()) :: GameQueue.t()
  def add_user_to_queue(queue, user_id) do
    Map.update(queue, :users, [], fn existing_users ->
      existing_users ++ [user_id]
    end)
  end

  @spec get_users_from_queue(queue :: GameQueue.t()) :: map()
  def get_users_from_queue(queue), do: get_users_from_queue(queue, queue.req_num_players)

  @spec get_users_from_queue(queue :: GameQueue.t(), number()) :: map()
  def get_users_from_queue(queue, num_of_users) do
    {users, new_users} = Enum.split(queue.users, num_of_users)
    new_queue = %{queue | users: new_users}
    %{new_queue: new_queue, users: users}
  end
end
