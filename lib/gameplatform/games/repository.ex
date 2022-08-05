defmodule Gameplatform.Games.Repository do
  alias Gameplatform.Repo
  alias Gameplatform.Games.Schema.Game

  def get_all_games do
    Repo.all(Game)
  end
end
