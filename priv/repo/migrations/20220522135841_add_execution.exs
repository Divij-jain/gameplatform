defmodule Gameplatform.Repo.Migrations.AddExecution do
  use Ecto.Migration

  def change do
    create_pgsql_extenstion()
  end

  defp create_pgsql_extenstion do
    execute "create EXTENSION IF NOT EXISTS plpgsql;"
    execute "create EXTENSION IF NOT EXISTS pgcrypto;"
  end
end
