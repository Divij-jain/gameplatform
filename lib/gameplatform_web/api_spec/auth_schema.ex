defmodule GameplatformWeb.ApiSpec.AuthSchema do
  require OpenApiSpex
  # alias OpenApiSpex.Schema

  alias __MODULE__

  defmodule PhoneNumber do
    OpenApiSpex.schema(%{
      type: :string,
      description: "Phone number",
      pattern: ~r/[1-9]{1}[0-9]{9}/
    })
  end

  defmodule CountryCode do
    OpenApiSpex.schema(%{
      type: :string,
      description: "Country code currently servicing for indian country only",
      pattern: ~r/\+91{1}$/
    })
  end

  defmodule Otp do
    OpenApiSpex.schema(%{
      type: :string,
      description: "OTP",
      pattern: ~r/[0-9]{6}/
    })
  end

  defmodule GetOtpRequest do
    OpenApiSpex.schema(%{
      title: "GetOtpRequest",
      description: "POST body for sending an otp to user",
      type: :object,
      properties: %{
        phone_number: AuthSchema.PhoneNumber,
        country_code: AuthSchema.CountryCode
      },
      required: [:phone_number, :country_code],
      example: %{
        "phone_number" => "1234567890",
        "country_code" => "+91"
      }
    })
  end

  defmodule SubmitOtpRequest do
    OpenApiSpex.schema(%{
      title: "SubmitOtpRequest",
      description: "POST body for verifying an otp submitted by user",
      type: :object,
      properties: %{
        phone_number: AuthSchema.PhoneNumber,
        country_code: AuthSchema.CountryCode,
        otp: Otp
      },
      required: [:phone_number, :country_code, :otp],
      example: %{
        "phone_number" => "1234567890",
        "country_code" => "+91",
        "otp" => "12345"
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
