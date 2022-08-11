defmodule Gameplatform.Repo.Migrations.CreateBannersTable do
  use Ecto.Migration

  def up do
    create_banners_table()
  end

  def down do
    drop_if_exists table("banners")
  end

  defp create_banners_table() do
    create_if_not_exists table("banners") do
      add :name, :string
      add :active, :boolean, default: false
      add :carousel_url, :string
      add :display_url, :string

      timestamps(
        type: :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end
  end
end
