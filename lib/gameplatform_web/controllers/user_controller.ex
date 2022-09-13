defmodule GameplatformWeb.UserController do
  use GameplatformWeb, :controller

  import OpenApiSpex.Operation, only: [response: 3, parameter: 5]

  alias Gameplatform.Account
  alias OpenApiSpex.Operation
  alias Gameplatform.ApiSpec.Schema

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  def open_api_operation(action) do
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def get_profile_operation() do
    %Operation{
      tags: ["User"],
      summary: "get profile of user",
      operationId: "UserController.get_profile",
      parameters: [
        parameter(
          :user_id,
          :path,
          :integer,
          "User ID",
          example: 123,
          required: true
        )
      ],
      responses: %{
        201 => response("GetProfile", "application/json", Schema.GetProfileResponse),
        422 => OpenApiSpex.JsonErrorResponse.response()
      }
    }
  end

  def get_profile(%{path_params: %{"user_id" => user_id}} = conn, _params) do
    case Account.get_complete_user(user_id) do
      {:ok, user} ->
        render(conn, "user.json", user: user)

      {:error, error} ->
        conn
        |> put_status(500)
        |> json(%{error: error})
    end
  end
end
