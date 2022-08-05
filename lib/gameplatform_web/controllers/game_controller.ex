defmodule GameplatformWeb.GameController do
  use GameplatformWeb, :controller

  import OpenApiSpex.Operation, only: [response: 3]

  alias GameplatformWeb.ApiSpec.Schema
  alias OpenApiSpex.Operation
  alias Gameplatform.Game
  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  def open_api_operation(action) do
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def list_games_operation() do
    %Operation{
      tags: ["Game"],
      summary: "list all the games",
      operationId: "GameController.list_games",
      responses: %{
        201 => response("ListGames", "application/json", Schema.ResponseListGames),
        422 => OpenApiSpex.JsonErrorResponse.response()
      }
    }
  end

  def list_games(conn, _params) do
    games = Game.get_all_games()
    json(conn, games)
  end
end
