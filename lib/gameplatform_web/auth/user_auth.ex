defmodule GameplatformWeb.Auth.UserAuth do
  import Plug.Conn

  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    # conn
    # |> renew_session()
    # |> put_session(:user_token, token)
    # |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    # |> maybe_write_remember_me_cookie(token, params)
    # |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end
end
