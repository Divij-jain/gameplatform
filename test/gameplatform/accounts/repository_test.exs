defmodule Gameplatform.Accounts.RepositoryTest do
  use Gameplatform.DataCase

  alias Gameplatform.Accounts.Repository
  alias Gameplatform.Accounts.Schema.{User, ReferralCode}
  alias Gameplatform.Test.Support.Helpers.Helper
  alias Gameplatform.Utils

  import Gameplatform.Factory

  describe "get queries" do
    setup do
      user = insert(:user)
      {:ok, %{user: user}}
    end

    test "get_user when no user exist" do
      assert {:ok, nil} == Repository.get_user(Ecto.UUID.generate())
    end

    test "get_user/1", %{user: user} do
      assert {:ok, db_user} = Repository.get_user(user.id)
      assert db_user.id == user.id
    end

    test "return nil get_user/1" do
      assert {:ok, nil} = Repository.get_user(Ecto.UUID.generate())
    end

    test "get_user_by_phone_number/1 when no user" do
      assert nil == Repository.get_user_by_phone_number("111111111")
    end

    test "get_user_by_phone_number/1", %{user: user} do
      db_user = Repository.get_user_by_phone_number(user.phone_number)
      assert db_user.phone_number == user.phone_number
    end

    test "get_wallet_balance/1", %{user: user} do
      [wallet | _] = user.user_profile.user_wallets
      {:ok, wallet_balance} = Repository.get_wallet_balance(wallet.id)
      assert Decimal.eq?(wallet_balance, 0)
    end
  end

  describe "create_new_user/1" do
    setup do
      phone_number = Helper.get_random_mobile_no()
      country_code = Helper.get_indian_country_code()

      {:ok, %{phone_number: phone_number, country_code: country_code}}
    end

    test "create_new_user/1", attrs do
      {:ok, %User{} = _user} = Repository.create_new_user(attrs)
    end
  end

  describe "create_referral_code/1" do
    test "creating suceeds" do
      user = insert(:user)
      referral_code = Utils.create_referral_code(user.user_profile.unique_id)
      attrs = %{user_profile_id: user.user_profile.id, referral_code: referral_code}
      assert {:ok, %ReferralCode{}} = Repository.create_referral_code(attrs)
    end
  end
end
