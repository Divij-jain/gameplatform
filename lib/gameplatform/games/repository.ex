defmodule Gameplatform.Games.Repository do
  @moduledoc false
  alias Gameplatform.Repo
  alias Gameplatform.Games.Queries
  alias Gameplatform.Games.Schema.{Game, Banner}

  import Ecto.Query

  @spec get_active_games :: list(Game.t()) | []
  def get_active_games() do
    Game
    |> Queries.get_active_games()
    |> Repo.all()
  end

  @spec get_active_banners :: list(Banner.t()) | []
  def get_active_banners() do
    Banner
    |> where([b], b.active == true)
    |> order_by([b], b.id)
    |> Repo.all()
  end

  @spec get_sku_list_for_all_games :: list(Game.t()) | []
  def get_sku_list_for_all_games() do
    Game
    |> Queries.get_all_games_with_sku_list()
    |> Repo.all()
  end
end
