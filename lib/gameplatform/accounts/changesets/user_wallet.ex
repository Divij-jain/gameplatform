defmodule Gameplatform.Accounts.Changesets.UserWallet do
  @moduledoc false
  import Ecto.Changeset

  alias Gameplatform.Accounts.Schema.UserWallet

  @params_required ~w(user_profile_id wallet_type)a
  @params_optional ~w()a

  def build(user_wallet \\ %UserWallet{}, attrs)

  def build(user_wallet, %_{} = attrs) do
    cast_params(user_wallet, Map.from_struct(attrs))
  end

  def build(user_wallet, attrs) do
    cast_params(user_wallet, attrs)
  end

  def cast_params(user_wallet, attrs) do
    user_wallet
    |> cast(attrs, @params_required ++ @params_optional)
    |> validate_required(@params_required)
    |> unique_constraint([:user_profile_id, :wallet_type])
    |> Map.put(:repo_opts, source: %UserWallet{}.__meta__.source)
  end
end
