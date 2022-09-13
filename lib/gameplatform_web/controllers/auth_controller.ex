defmodule GameplatformWeb.AuthController do
  use GameplatformWeb, :controller

  import OpenApiSpex.Operation, only: [request_body: 4, response: 3]

  alias OpenApiSpex.Operation
  alias Gameplatform.Auth
  alias Gameplatform.Auth.Token.TokenClient
  alias Gameplatform.Account
  alias Gameplatform.ApiSpec.Schema
  alias GameplatformWeb.Plugs.UserAuth, as: AuthPlug
  alias GameplatformWeb.Utils

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  def open_api_operation(action) do
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def get_otp_operation() do
    %Operation{
      tags: ["Auth"],
      summary: "send otp to user",
      description: "Send Otp to users",
      operationId: "AuthController.get_otp",
      requestBody:
        request_body(
          "The getOtp request attributes",
          "application/json",
          Schema.GetOtpRequest,
          required: true
        ),
      responses: %{
        201 =>
          response("Request submitted Response", "application/json", Schema.RequestSubmitted),
        422 => OpenApiSpex.JsonErrorResponse.response()
      }
    }
  end

  def get_otp(conn, _params) do
    body_params = Map.get(conn, :body_params)

    case Auth.send_otp_to_user(body_params) do
      {:ok, body} ->
        resp = Utils.make_response("OK", body)
        json(conn, resp)

      {:error, status_code, error} ->
        conn
        |> put_status(status_code)
        |> json(%{errors: error})
    end
  end

  def submit_otp_operation() do
    %Operation{
      tags: ["Auth"],
      summary: "verify otp submitted from user",
      description: "verify otp submitted by user",
      operationId: "AuthController.submit_otp",
      requestBody:
        request_body(
          "The submit_otp request attributes",
          "application/json",
          Schema.SubmitOtpRequest,
          required: true
        ),
      responses: %{
        201 =>
          response("Request submitted Response", "application/json", Schema.RequestSubmitted),
        422 => OpenApiSpex.JsonErrorResponse.response()
      }
    }
  end

  def submit_otp(conn, _params) do
    body_params = Map.get(conn, :body_params)

    with {:ok, true} <- Auth.verify_otp(body_params),
         {:ok, user} <- Account.get_current_user(body_params),
         {:ok, auth_token} <- TokenClient.create_new_token(user) do
      resp =
        Utils.make_response("OK", "SignIn Successful", %{token: auth_token, user_id: user.id})

      json(conn, resp)
    else
      {:error, status_code, error} ->
        conn
        |> put_status(status_code)
        |> json(%{errors: error})

      _err ->
        conn
        |> put_status(500)
        |> json(%{error: "to parse changeset and check error code"})
    end
  end

  def log_out_operation() do
    %Operation{
      tags: ["Auth"],
      summary: "log out user",
      operationId: "AuthController.log_out",
      responses: %{
        422 => OpenApiSpex.JsonErrorResponse.response()
      }
    }
  end

  def log_out(conn, _params) do
    conn
    |> AuthPlug.log_out_user()
    |> json(%{})
  end
end
