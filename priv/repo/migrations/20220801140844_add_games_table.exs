defmodule Gameplatform.Repo.Migrations.AddGamesTable do
  use Ecto.Migration

  def up do
    create_games_table()
  end

  def down do
    drop_if_exists table("games")
  end

  defp create_games_table() do
    create_if_not_exists table("games") do
      add :name, :string
      add :active, :boolean, default: false
      add :game_hash, :string
      add :app_id, :string
      add :image_url, :string
      add :play_mode, :string

      timestamps(
        type: :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end
  end
end
