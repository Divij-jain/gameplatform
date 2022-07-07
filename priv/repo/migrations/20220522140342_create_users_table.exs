defmodule Gameplatform.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :phone_number, :string, null: false
      add :country_code, :string, null: false

      timestamps(
        type: :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end
  end
end
