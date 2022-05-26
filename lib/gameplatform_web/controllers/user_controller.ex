defmodule GameplatformWeb.UserController do
  use GameplatformWeb, :controller

  alias Gameplatform.Impl.Auth.Auth
  alias Gameplatform.Account
  alias GameplatformWeb.Auth.UserAuth

  def get_otp(conn, params) do
    case Auth.send_otp_to_user(params) do
      {:ok, _} ->
        json(conn, %{})

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
            conn
            |> put_flash(:info, "User Registered successfully.")
            |> UserAuth.log_in_user(user)
        end

      {:error_, _status_code, _error} ->
        :ok
    end

    conn
  end
end
