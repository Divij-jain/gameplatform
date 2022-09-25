defmodule Gameplatform.Games.Runtime.Model.Game do
  @moduledoc """
  Defines the structure of game server
  """

  alias __MODULE__

  defmodule Player do
    @moduledoc """
    Defines the structure of game player
    """

    defstruct [:user_id, :user_channel]

    @type t :: %__MODULE__{
            user_id: integer(),
            user_channel: String.t()
          }

    def new(args) do
      %{user_id: user_id, user_channel: user_channel} = args

      %__MODULE__{
        user_id: user_id,
        user_channel: user_channel
      }
    end
  end

  defstruct [:game_id, :app_id, :sku_code, :req_num_players, :amount, :players, :table_id]

  @type t :: %__MODULE__{
          game_id: String.t(),
          app_id: String.t(),
          sku_code: String.t(),
          amount: number(),
          req_num_players: number(),
          table_id: String.t(),
          players: list(Player.t())
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
