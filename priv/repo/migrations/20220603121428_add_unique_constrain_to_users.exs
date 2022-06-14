defmodule Gameplatform.Repo.Migrations.AddUniqueConstrainToUsers do
  use Ecto.Migration

  def change do
    create unique_index("users", [:phone_number])
  end
end
