defmodule GameplatformWeb.UserSocketTest do
  use GameplatformWeb.ChannelCase
  use Mimic

  @moduledoc """
  Test for UserSocket
  """

  alias GameplatformWeb.UserSocket
  alias Gameplatform.Auth.Token.TokenClient
  alias GameplatformWeb.ApiToConfig

  describe "connect/3" do
    test "connection fails on missing token" do
      assert :error = connect(UserSocket, %{})
    end

    test "connection fails on invalid token" do
      connect(UserSocket, %{"token" => "abcd"})

      token = Jason.encode!("abcd")
      connect(UserSocket, %{"token" => token})
    end

    test "connection suceeds on correct token" do
      mock_token(Ecto.UUID.generate())

      token = Jason.encode!("abcd")
      assert {:ok, %Phoenix.Socket{}} = connect(UserSocket, %{"token" => token})
    end
  end

  describe "id/1" do
    test "returns id" do
      id = Ecto.UUID.generate()
      mock_token(id)

      token = Jason.encode!("abcd")
      assert {:ok, %Phoenix.Socket{} = socket} = connect(UserSocket, %{"token" => token})

      socket_id = ApiToConfig.socket_id()
      assert socket_id <> id == UserSocket.id(socket)
    end
  end

  defp mock_token(user_id) do
    expect(TokenClient, :get_user_id_by_jwt_token, fn _token ->
      {:ok, user_id}
    end)
  end
end
