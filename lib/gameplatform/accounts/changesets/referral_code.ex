defmodule Gameplatform.Accounts.Changesets.ReferralCode do
  @moduledoc """
  Module to implement referral code changeset
  """

  import Ecto.Changeset

  @params_required ~w(user_profile_id referral_code)a
  @params_optional ~w(id active)a

  alias Gameplatform.Accounts.Schema.ReferralCode

  def build(attrs) do
    cast_params(%ReferralCode{}, attrs)
  end

  def cast_params(referral, attrs) do
    referral
    |> cast(attrs, @params_required ++ @params_optional)
    |> validate_required(@params_required)
    |> unique_constraint(:referral_code)
    |> Map.put(:repo_opts, source: %ReferralCode{}.__meta__.source)
  end
end
