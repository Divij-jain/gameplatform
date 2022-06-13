defmodule GameplatformWeb.ApiSpec do
  @moduledoc """
  OpenAPI spec for gameplatform
  """
  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  # Components, SecurityScheme}
  alias GameplatformWeb.{Endpoint, Router}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    version =
      :gameplatform
      |> Application.spec(:vsn)
      |> List.to_string()

    %OpenApi{
      servers: [
        # Populate the Server info from a phoenix endpoint
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "Gameplatform App",
        version: version
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router)
      # components: %Components{
      #   securitySchemes:
      #   %{"authorization" => %SecurityScheme{
      #     type: "http",
      #      scheme: "bearer"
      #      }
      #     }
      # }
    }
    # Discover request/response schemas from path specs
    |> OpenApiSpex.resolve_schema_modules()
  end
end
