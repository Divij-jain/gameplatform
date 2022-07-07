defmodule Gameplatform.Accounts.Changesets.UserProfile do
  import Ecto.Changeset

  alias Gameplatform.Accounts.Schema.UserProfile
  alias Gameplatform.Accounts.Changesets

  @params_required ~w(user_id phone_number)a
  @params_optional ~w(email first_name second_name kyc_status )a

  def build(user_profile \\ %UserProfile{}, attrs)

  def build(user_profile, %_{} = attrs) do
    cast_params(user_profile, Map.from_struct(attrs))
  end

  def build(user_profile, attrs) do
    cast_params(user_profile, attrs)
  end

  def cast_params(user_profile, attrs) do
    user_profile
    |> cast(attrs, @params_required ++ @params_optional)
    |> validate_required(@params_required)
    |> Map.put(:repo_opts, source: %UserProfile{}.__meta__.source)
  end

  def assoc_user_wallet(changeset) do
    cast_assoc(changeset, :user_wallets,
      require: true,
      with: &Changesets.UserWallet.build/2
    )
  end
end
