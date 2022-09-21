defmodule Gameplatform.Games.RepositoryTest do
  use Gameplatform.DataCase

  alias Gameplatform.Games.Repository

  import Gameplatform.Factory

  describe "get_active_banners/0" do
    test "returns [] when no active banner exists" do
      assert [] == Repository.get_active_banners()

      insert(:banner, %{active: false})
      assert [] == Repository.get_active_banners()
    end

    test "returns list of banners" do
      banner = insert(:banner)
      assert [banner] == Repository.get_active_banners()
    end
  end

  describe "get_sku_list_for_all_games/0" do
    test "returns [] when no game" do
      assert [] == Repository.get_active_games()
    end

    test "returns get_sku_list_for_all_games" do
      game = insert(:game)

      assert [game] == Repository.get_sku_list_for_all_games()
    end
  end
end
