defmodule Gameplatform.Accounts.Changesets.User do
  @moduledoc """
  Module to implement user changeset.
  """
  import Ecto.Changeset

  alias Gameplatform.Accounts.Schema.User
  alias Gameplatform.Accounts.Changesets.UserProfile

  @params_required ~w(phone_number country_code)a
  @params_optional ~w(id)a

  def build(user \\ %User{}, attrs)

  def build(user, %_{} = attrs) do
    cast_params(user, Map.from_struct(attrs))
  end

  def build(user, attrs) do
    cast_params(user, attrs)
  end

  def cast_params(user, attrs) do
    user
    |> cast(attrs, @params_required ++ @params_optional)
    |> validate_required(@params_required)
    |> Map.put(:repo_opts, source: %User{}.__meta__.source)
  end

  def assoc_user_profile(changeset) do
    cast_assoc(changeset, :user_profiles,
      require: true,
      with: &UserProfile.build/2
    )
  end
end
