defmodule Gameplatform.Accounts.Schema.ReferralCode do
  use Gameplatform.Schema

  @moduledoc false

  alias Gameplatform.Accounts.Schema.UserProfile

  @type t() :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_profile_id: Ecto.UUID.t(),
          referral_code: String.t(),
          active: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "referrals" do
    field :referral_code, :string
    field :active, :boolean
    timestamps(type: :utc_datetime)

    belongs_to :user_profile, UserProfile
  end
end
