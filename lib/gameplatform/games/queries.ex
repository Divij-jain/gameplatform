defmodule Gameplatform.Games.Queries do
  @moduledoc """
  for db queries
  """

  import Ecto.Query

  # to change the alias
  alias Gameplatform.Games.Schema.GameSku

  def get_all_games_with_sku_list(query) do
    from(game in query,
      left_join: gamesku in GameSku,
      on: game.id == gamesku.game_id,
      preload: [game_skus: gamesku]
    )
  end
end
