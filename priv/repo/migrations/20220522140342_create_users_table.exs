defmodule Gameplatform.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :mobile_number, :string, null: false
      add :country_code, :string, null: false

      add :created_at, :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false

      add :updated_at, :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false
    end
  end
end
