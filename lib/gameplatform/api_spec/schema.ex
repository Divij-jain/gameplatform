defmodule Gameplatform.ApiSpec.Schema do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  defmodule Integer do
    @moduledoc false

    OpenApiSpex.schema(%{
      titile: "Integer",
      type: :integer
    })
  end

  defmodule String do
    @moduledoc false

    OpenApiSpex.schema(%{
      titile: "Integer",
      type: :string
    })
  end

  defmodule Boolean do
    @moduledoc false

    OpenApiSpex.schema(%{
      titile: "Boolean",
      type: :boolean
    })
  end

  defmodule UtcDateTime do
    @moduledoc false

    OpenApiSpex.schema(%{
      titile: "UtcDateTime",
      type: :string,
      format: :"date-time"
    })
  end

  defmodule PhoneNumber do
    @moduledoc false

    OpenApiSpex.schema(%{
      titile: "PhoneNumber",
      type: :string
    })
  end

  defmodule Email do
    @moduledoc false

    OpenApiSpex.schema(%{
      titile: "Email address",
      type: :string,
      format: :email
    })
  end

  defmodule CountryCode do
    @moduledoc false

    OpenApiSpex.schema(%{
      type: :string,
      description: "Country code currently servicing for indian country only",
      pattern: ~r/\+91{1}$/
    })
  end

  defmodule Otp do
    @moduledoc false

    OpenApiSpex.schema(%{
      type: :string,
      description: "OTP",
      pattern: ~r/[0-9]{6}/
    })
  end

  defmodule UserProfile do
    @moduledoc false

    OpenApiSpex.schema(%{
      titile: "UserProfile",
      type: :object,
      properties: %{
        id: Integer,
        phone_number: PhoneNumber,
        email: Email,
        first_name: String,
        second_name: String,
        kyc_status: Boolean,
        gender: String,
        image: String,
        inserted_at: UtcDateTime,
        updated_at: UtcDateTime
      }
    })
  end

  defmodule UserWallet do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "UserWallet",
      type: :object,
      properties: %{
        id: Integer,
        wallet_type: String,
        inserted_at: UtcDateTime,
        updated_at: UtcDateTime
      }
    })
  end

  defmodule GetProfileResponse do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "GetProfileResponse",
      type: :object,
      properties: %{
        status_code: String,
        message: String,
        data: %Schema{
          type: :object,
          properties: %{
            user_profile: UserProfile,
            user_wallets: %Schema{
              type: :array,
              items: UserWallet
            }
          }
        }
      }
    })
  end

  defmodule GetOtpRequest do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "GetOtpRequest",
      description: "POST body for sending an otp to user",
      type: :object,
      properties: %{
        phone_number: PhoneNumber,
        country_code: CountryCode
      },
      required: [:phone_number, :country_code],
      example: %{
        "phone_number" => "1234567890",
        "country_code" => "+91"
      }
    })
  end

  defmodule SubmitOtpRequest do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "SubmitOtpRequest",
      description: "POST body for verifying an otp submitted by user",
      type: :object,
      properties: %{
        phone_number: PhoneNumber,
        country_code: CountryCode,
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

    OpenApiSpex.schema(
      %{
        title: "Request submitted response",
        type: :object,
        properties: %{
          status_code: String,
          message: String
        }
      },
      example: %{
        status_code: "OK",
        message: "some message"
      }
    )
  end

  defmodule AuthResponse do
    @moduledoc false

    OpenApiSpex.schema(
      %{
        title: "Request submitted response",
        type: :object,
        properties: %{
          status_code: String,
          message: String,
          data: %Schema{
            type: :object,
            properties: %{
              token: String,
              user_id: Integer
            }
          }
        }
      },
      example: %{
        status_code: "OK",
        message: "some message"
      }
    )
  end

  defmodule ListGamesResponse do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "ListGamesResponse",
      type: :object,
      properties: %{
        status_code: String,
        message: String,
        data: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            properties: %{
              id: String,
              active: Boolean,
              name: String,
              game_hash: String,
              app_id: String,
              image_url: String,
              play_mode: String
            }
          }
        }
      }
    })
  end

  defmodule ListBannersResponse do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "ListBannersResponse",
      type: :object,
      properties: %{
        status_code: String,
        message: String,
        data: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            properties: %{
              id: String,
              active: Boolean,
              name: String,
              carousel_url: String,
              display_url: String
            }
          }
        }
      }
    })
  end
end
