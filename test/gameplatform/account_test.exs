defmodule Gameplatform.AccountTest do
  use Gameplatform.DataCase

  alias Gameplatform.Account
  alias Gameplatform.Test.Support.Helpers.AuthHelper
  alias Gameplatform.Accounts.Schema.User

  describe "create new user/1" do
    test "creation fails on missing params" do
      params = %{phone_number: "1234567890"}

      assert {:error, %{country_code: ["can't be blank"]}} = Account.create_new_user(params)
    end

    test "creation fails on invalid params" do
      params = %{phone_number: 1_234_567_890, country_code: "+91"}

      assert {:error, %{phone_number: ["is invalid"]}} = Account.create_new_user(params)
    end

    test "creation fails on validation error " do
      params = %{phone_number: 1_234_567_890, country_code: "+91"}

      assert {:error, %{phone_number: ["is invalid"]}} = Account.create_new_user(params)
    end

    test "creating user succeeds" do
      phone_number = AuthHelper.get_random_mobile_no()
      params = %{phone_number: phone_number, country_code: "+91"}
      {:ok, %User{} = user} = Account.create_new_user(params)
      assert_created_user(user, params)
    end
  end

  defp assert_created_user(%User{} = user, params) do
    assert user.phone_number == params.phone_number
    assert user.country_code == params.country_code
    assert user.id
    assert user.inserted_at
    assert user.updated_at
  end
end
