defmodule Gameplatform.Games.Schema.GameSku do
  @moduledoc false

  use Gameplatform.Schema

  alias Gameplatform.Games.Schema.Game

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          sku_name: String.t(),
          sku_code: String.t(),
          sku_image: String.t(),
          amount: Decimal.t(),
          active: boolean(),
          num_players: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          game_id: Ecto.UUID.t()
        }

  schema "game_skus" do
    field :sku_name, :string
    field :sku_code, :string
    field :sku_image, :string
    field :amount, :decimal
    field :active, :boolean
    field :num_players, :integer

    timestamps(type: :utc_datetime)

    belongs_to :game, Game
  end
end
