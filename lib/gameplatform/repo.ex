defmodule Gameplatform.Repo do
  use Ecto.Repo,
    otp_app: :gameplatform,
    adapter: Ecto.Adapters.Postgres
end
