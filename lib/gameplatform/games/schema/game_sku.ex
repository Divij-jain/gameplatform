defmodule Gameplatform.Games.Schema.GameSku do
  use Ecto.Schema

  alias Gameplatform.Games.Schema.Game

  schema "game_skus" do
    field :sku_code, :string
    field :amount, :decimal
    field :active, :boolean
    timestamps(type: :utc_datetime)

    belongs_to :game, Game
  end
end
