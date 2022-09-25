defmodule GameplatformWeb.MainAppChannelTest do
  use GameplatformWeb.ChannelCase
  use Mimic

  alias GameplatformWeb.UserSocket
  alias GameplatformWeb.ApiToConfig
  alias Gameplatform.Users.UserSupervisor

  import ExUnit.CaptureLog

  setup_all do
    user_id = Ecto.UUID.generate()
    assigns = %{user_id: user_id}
    socket_id = ApiToConfig.socket_id() <> user_id
    socket = socket(UserSocket, socket_id, assigns)

    {:ok, %{socket: socket, user_id: user_id}}
  end

  describe "join/3" do
    test "joining main:app user channel suceeds", %{socket: socket, user_id: user_id} do
      mock_start_user_process(user_id, {:ok, "anything"})

      {:ok, _, %Phoenix.Socket{} = _socket} =
        subscribe_and_join(socket, "main_app:user:" <> user_id)
    end

    test "joining main:app user channel fails on unauthorized?", %{socket: socket} do
      user_id = Ecto.UUID.generate()

      assert capture_log(fn ->
               assert {:error, %{reason: "unauthorized"}} =
                        subscribe_and_join(socket, "main_app:user:" <> user_id)
             end)
    end

    test "joining main:app user channel fails on non starting process", %{
      socket: socket,
      user_id: user_id
    } do
      mock_start_user_process(user_id, {:error, "any error"})

      assert {:error, %{reason: "any error"}} =
               subscribe_and_join(socket, "main_app:user:" <> user_id)
    end
  end

  describe "handle_in/3" do
    setup do
      user_id = Ecto.UUID.generate()
      socket = subscribe_to_channel(user_id)
      {:ok, %{socket: socket}}
    end

    test "ping", %{socket: socket} do
      message = %{"msg" => "hello"}
      ref = push(socket, "ping", message)
      assert_reply ref, :ok, ^message
    end

    test "pong no reply to the client", %{socket: socket} do
      message = %{"msg" => "hello"}
      _ref = push(socket, "pong", message)

      refute_push("pong", ^message)
    end

    # test "shutdown to close down the channel", %{socket: socket} do
    #   assert_raise("(EXIT from #PID<0.682.0>) shutdown", fn -> push(socket, "stop", %{}) end)
    # end
  end

  defp subscribe_to_channel(user_id) do
    assigns = %{user_id: user_id}
    socket_id = ApiToConfig.socket_id() <> user_id
    socket = socket(UserSocket, socket_id, assigns)

    mock_start_user_process(user_id, {:ok, "anything"})

    {:ok, _, %Phoenix.Socket{} = socket} =
      subscribe_and_join(socket, GameplatformWeb.MainAppChannel, "main_app:user:" <> user_id)

    socket
  end

  defp mock_start_user_process(user_id, return_value) do
    expect(UserSupervisor, :start_user_process, fn ^user_id, _ ->
      return_value
    end)
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push(socket, "ping", %{"hello" => "there"})
  #   assert_reply ref, :ok, %{"hello" => "there"}
  # end

  # test "shout broadcasts to main_app:lobby", %{socket: socket} do
  #   push(socket, "shout", %{"hello" => "all"})
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end

  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from!(socket, "broadcast", %{"some" => "data"})
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
