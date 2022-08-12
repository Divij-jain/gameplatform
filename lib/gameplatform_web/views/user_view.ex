defmodule GameplatformWeb.UserView do
  use GameplatformWeb, :view

  alias GameplatformWeb.ApiSpec.Schema
  alias GameplatformWeb.Utils

  def render("user.json", %{user: user}) do
    %{
      user_profile: extract_user_profile(user.user_profiles),
      user_wallets: parse_user_wallets(user.user_profiles.user_wallets)
    }
  end

  defp parse_user_wallets(%_{} = user_wallet) do
    extract_user_wallet(user_wallet)
  end

  defp parse_user_wallets([]), do: []

  defp parse_user_wallets([user_wallet | _user_wallets]) do
    parse_user_wallets(user_wallet)
  end

  defp extract_user_wallet(user_wallet) do
    Map.take(user_wallet, [
      :id,
      :user_wallet,
      :updated_at,
      :inserted_at
    ])
  end

  defp extract_user_profile(user_profiles) do
    Map.take(user_profiles, [
      :email,
      :first_name,
      :second_name,
      :kyc_status,
      :phone_number,
      :gender,
      :image
    ])
  end
end
