defmodule GameplatformWeb.ApiSpec.AuthSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule GetOtpRequest do
    OpenApiSpex.schema(%{
      title: "GetOtpRequest",
      description: "POST body for sending an otp to user",
      type: :object,
      properties: %{
        phone_number: %Schema{
          type: :string,
          description: "Phone number",
          pattern: ~r/[a-zA-Z][a-zA-Z0-9_]+/
        },
        country_code: %Schema{
          type: :string,
          description: "Country code",
          pattern: ~r/[a-zA-Z][a-zA-Z0-9_]+/
        }
      },
      required: [:phone_number, :country_code],
      example: %{
        "phone_number" => "1234567890",
        "country_code" => "+91"
      }
    })
  end

  defmodule RequestSubmitted do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Request submitted response",
      type: :object,
      properties: %{},
      example: %{}
    })
  end
end
