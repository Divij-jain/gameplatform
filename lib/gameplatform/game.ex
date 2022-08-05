defmodule Gameplatform.Game do
  alias Gameplatform.Games.Repository, as: Repo

  def get_all_games() do
    Repo.get_all_games()
  end
end
