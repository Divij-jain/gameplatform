defmodule GameplatformWeb.AuthController do
  use GameplatformWeb, :controller

  alias Gameplatform.Auth
  alias Gameplatform.Account
  alias GameplatformWeb.Plugs.UserAuth, as: AuthPlug

  def get_otp(conn, params) do
    case Auth.send_otp_to_user(params) do
      {:ok, body} ->
        json(conn, body)

      {:error, status_code, error} ->
        conn
        |> put_status(status_code)
        |> json(%{errors: error})
    end
  end

  def submit_otp(conn, params) do
    with {:ok, true} <- Auth.verify_otp(params),
         {:ok, user} <- Account.get_current_user(params) do
      conn
      |> AuthPlug.log_in_user(user, %{"remember_me" => "true"})
      |> json(%{result: "success"})
    else
      {:error, status_code, error} ->
        conn
        |> put_status(status_code)
        |> json(%{errors: error})

      _ ->
        conn
        |> put_status(500)
        |> json(%{error: "to parse changeset and check error code"})
    end
  end

  def log_out(conn, _params) do
    conn
    |> AuthPlug.log_out_user()
    |> json(%{})
  end
end
