defmodule Gameplatform.Accounts.Schema.User do
  use Gameplatform.Schema

  @moduledoc false

  alias Gameplatform.Accounts.Schema.UserProfile

  @type t() :: %__MODULE__{
          id: Ecto.UUID.t(),
          phone_number: String.t(),
          country_code: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          user_profile: UserProfile.t()
        }

  schema "users" do
    field :phone_number, :string
    field :country_code, :string
    timestamps(type: :utc_datetime_usec)

    has_one :user_profile, UserProfile, foreign_key: :user_id
  end
end
