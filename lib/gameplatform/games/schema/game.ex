defmodule Gameplatform.Games.Schema.Game do
  use Ecto.Schema

  schema "games" do
    field :name, :string
    field :active, :boolean
    field :game_hash, :string
    field :app_id, :string
    field :image_url, :string
    field :gameplay_url, :string
    field :play_mode, :string

    timestamps(type: :utc_datetime_usec)
  end
end
