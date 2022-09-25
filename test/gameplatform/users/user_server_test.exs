defmodule Gameplatform.Users.UserServerTest do
  use Gameplatform.DataCase

  alias Gameplatform.Accounts.Schema.User
  alias Gameplatform.Users.UserServer
  alias Gameplatform.Users.Model.UserServer, as: UserModel
  alias GameplatformWeb.ApiToConfig

  import Gameplatform.Factory

  describe "start_link/1" do
    # we could have also called UserServer.start_link() but the benefit of
    # start_supervised is that it gives an on fly supervisor which gracefully exits child procs
    # and itself before proceeding to next server.
    test "succesful start of genserver" do
      user_id = Ecto.UUID.generate()
      user_channel = ApiToConfig.channel_prefix() <> user_id
      opts = %{user_id: user_id, user_channel: user_channel}
      assert {:ok, pid} = start_supervised({UserServer, opts})
      assert is_pid(pid) == true
    end

    test "init fails on missiong params" do
      assert {:error, _e} = start_supervised({UserServer, %{}})
    end
  end

  # these could could require use of WaitForIt library
  describe "tests for checking state" do
    test "anything" do
      %User{} = user = insert(:user)
      games = insert_pair(:game)
      banners = insert_pair(:banner)

      user_channel = ApiToConfig.channel_prefix() <> user.id
      opts = %{user_id: user.id, user_channel: user_channel}
      {:ok, pid} = start_supervised({UserServer, opts})
      assert %UserModel{} = state = :sys.get_state(pid)

      map = %{user: user, user_channel: user_channel, banners: banners, games: games}
      assert_state(state, map)
    end
  end

  defp assert_state(%UserModel{} = state, map) do
    %{user: user, user_channel: user_channel, banners: banners, games: games} = map
    assert state.user_id == user.id
    assert state.user_channel == user_channel
    assert state.profile == user.user_profile

    assert_member(games, state.games)
    assert_member(banners, state.banners)
  end

  defp assert_member(list, key_list) do
    Enum.all?(list, fn value ->
      Enum.member?(key_list, value)
    end)
  end
end
