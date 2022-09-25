defmodule Gameplatform.Accounts.Changesets.UserWalletTx do
  @moduledoc false
  import Ecto.Changeset

  alias Gameplatform.Accounts.Schema.UserWalletTx

  @params_required ~w(meta_tx_id user_wallet_id amount tx_type)a
  @params_optional ~w()a

  def build(user_wallet_tx \\ %UserWalletTx{}, attrs)

  def build(user_wallet_tx, %_{} = attrs) do
    cast_params(user_wallet_tx, Map.from_struct(attrs))
  end

  def build(user_wallet_tx, attrs) do
    cast_params(user_wallet_tx, attrs)
  end

  def cast_params(user_wallet_tx, attrs) do
    user_wallet_tx
    |> cast(attrs, @params_required ++ @params_optional)
    |> validate_required(@params_required)
    |> foreign_key_constraint(:user_wallet_id)
    |> Map.put(:repo_opts, source: %UserWalletTx{}.__meta__.source)
  end
end
