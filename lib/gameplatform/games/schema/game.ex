defmodule Gameplatform.Games.Schema.Game do
  use Ecto.Schema

  alias Gameplatform.Games.Schema.GameSku

  @type t :: %__MODULE__{
          id: number(),
          name: String.t(),
          active: boolean(),
          game_hash: String.t(),
          app_id: String.t(),
          image_url: String.t(),
          gameplay_url: String.t(),
          play_mode: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          game_skus: list(GameSku.t())
        }

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
