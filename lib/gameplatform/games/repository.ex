defmodule Gameplatform.Games.Repository do
  alias Gameplatform.Repo
  import Ecto.Query
  alias Gameplatform.Games.Schema.{Game, Banner}

  def get_active_games() do
    Game
    |> where([g], g.active == true)
    |> order_by([g], g.id)
    |> Repo.all()
  end

  def get_active_banners() do
    Banner
    |> where([b], b.active == true)
    |> order_by([b], b.id)
    |> Repo.all()
  end

  def get_sku_list_for_all_games() do
    Game
    |> Queries.get_all_games_with_sku_list()
    |> Repo.all()
  end
end
