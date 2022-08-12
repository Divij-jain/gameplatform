defmodule Gameplatform.Games.Schema.Game do
  use Ecto.Schema

  alias Gameplatform.Games.Schema.GameSku

  schema "games" do
    field :name, :string
    field :active, :boolean
    field :game_hash, :string
    field :app_id, :string
    field :image_url, :string
    field :gameplay_url, :string
    field :play_mode, :string

    timestamps(type: :utc_datetime_usec)

    has_many :game_skus, GameSku, foreign_key: :game_id
  end
end
