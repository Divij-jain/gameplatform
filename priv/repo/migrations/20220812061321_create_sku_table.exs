defmodule Gameplatform.Repo.Migrations.CreateSkuTable do
  use Ecto.Migration

  def up do
    create_game_sku_table()
  end

  def down do
    drop_if_exists table("game_skus")
  end

  defp create_game_sku_table do
    create_if_not_exists table("game_skus") do
      add :game_id, references("games"), null: false
      add :sku_code, :string, null: false
      add :sku_name, :string, null: false
      add :sku_image, :string, null: false
      add :amount, :float, default: 0
      add :active, :boolean, default: true

      timestamps(
        type: :utc_datetime,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end

    create unique_index(:game_skus, [:sku_code])
  end
end
