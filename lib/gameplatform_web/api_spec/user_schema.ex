defmodule GameplatformWeb.ApiSpec.UserSchema do
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

  defmodule ResponseGetProfile do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "ResponseGetProfile",
      type: :object,
      properties: %{
        user_profile: UserProfile,
        user_wallets: %Schema{
          type: :array,
          items: UserWallet
        }
      }
    })
  end
end
