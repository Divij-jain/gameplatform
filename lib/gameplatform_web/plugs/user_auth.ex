defmodule GameplatformWeb.Plugs.UserAuth do
  @moduledoc """
    Module for making user authentication.
  """
  import Plug.Conn
  use GameplatformWeb, :controller

  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_gameplatform_web_user_token"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  alias Gameplatform.Auth.Token.TokenClient

  def log_in_user(conn, user, params \\ %{}) do
    token = TokenClient.create_new_token(user)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> maybe_write_remember_me_cookie(token, params)
  end

  def get_auth_token(user, _params \\ %{}), do: TokenClient.create_new_token(user)

  def log_out_user(conn) do
    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
  end

  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user_data = user_token && TokenClient.get_user_id_by_jwt_token(user_token)
    assign(conn, :current_user, user_data)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> json(%{error: "user unauthenticated"})
      |> halt()
    end
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

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end
end
