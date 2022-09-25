defmodule Gameplatform.Game do
  @moduledoc false
  alias Gameplatform.Games.Repository, as: Repo

  def get_active_games() do
    Repo.get_active_games()
  end

  def get_active_banners() do
    Repo.get_active_banners()
  end
end
