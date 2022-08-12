defmodule Gameplatform.GameQueue.GameQueue do
  @moduledoc """
  Defines the structure of game queue
  """

  defstruct [:users, :game_id, :sku_code, :amount]

  @type t :: %__MODULE__{
          users: list(),
          game_id: String.t(),
          sku_code: String.t(),
          amount: number()
        }

  @spec new(map()) :: Gameplatform.GameQueue.GameQueue.t()
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
end
