defmodule GameplatformWeb.UserController do
  use GameplatformWeb, :controller

  alias Gameplatform.Auth
  alias Gameplatform.Account
  alias GameplatformWeb.Auth.UserAuth

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
    case Auth.verify_otp(params) do
      true ->
        case Account.register_user(params) do
          {:ok, user} ->
            IO.inspect(user)

            conn
            |> UserAuth.log_in_user(user, %{"remember_me" => "true"})

          _ ->
            conn
        end

      {:error_, _status_code, _error} ->
        conn

      _ ->
        conn
    end
  end

  def log_out(conn, _params) do
    IO.inspect(conn, label: "log_out")
    UserAuth.log_out_user(conn)
  end
end
