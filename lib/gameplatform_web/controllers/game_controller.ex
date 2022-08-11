defmodule GameplatformWeb.GameController do
  use GameplatformWeb, :controller

  import OpenApiSpex.Operation, only: [response: 3]

  alias Gameplatform.Game
  alias GameplatformWeb.ApiSpec.Schema
  alias GameplatformWeb.Utils
  alias OpenApiSpex.Operation

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  def open_api_operation(action) do
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def list_games_operation() do
    %Operation{
      tags: ["Game"],
      summary: "Api to list all the games.",
      operationId: "GameController.list_games",
      responses: %{
        201 => response("ListGames", "application/json", Schema.ListGamesResponse),
        422 => OpenApiSpex.JsonErrorResponse.response()
      }
    }
  end

  def list_games(conn, _params) do
    games = Game.get_active_games()
    games = Enum.map(games, &Utils.schema_struct_to_map/1)
    resp = Utils.make_response("OK", "", games)
    json(conn, resp)
  end

  def list_banners_operation() do
    %Operation{
      tags: ["Banners"],
      summary: "Api to list all the banners.",
      operationId: "GameController.list_banners",
      responses: %{
        201 => response("ListGames", "application/json", Schema.ListBannersResponse),
        422 => OpenApiSpex.JsonErrorResponse.response()
      }
    }
  end

  def list_banners(conn, _params) do
    banners = Game.get_active_banners()
    banners = Enum.map(banners, &Utils.schema_struct_to_map/1)
    resp = Utils.make_response("OK", "", banners)
    json(conn, resp)
  end
end
