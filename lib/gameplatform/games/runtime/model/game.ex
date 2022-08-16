defmodule Gameplatform.Games.Runtime.Model.Game do
  @moduledoc """
  Defines the structure of game server
  """

  alias __MODULE__

  defstruct [:game_id, :app_id, :sku_code, :req_num_players, :amount, :players, :table_id]

  @type t :: %__MODULE__{
          game_id: String.t(),
          app_id: String.t(),
          sku_code: String.t(),
          amount: number(),
          req_num_players: number()
        }

  @spec new(map()) :: Game.t()
  def new(args) do
    %{
      game_id: game_id,
      app_id: app_id,
      sku_code: sku_code,
      amount: sku_amount,
      req_num_players: num,
      table_id: table_id
    } = args

    %__MODULE__{
      game_id: game_id,
      app_id: app_id,
      sku_code: sku_code,
      amount: sku_amount,
      req_num_players: num,
      table_id: table_id,
      players: []
    }
  end
end
