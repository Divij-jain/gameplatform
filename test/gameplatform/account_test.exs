defmodule Gameplatform.AccountTest do
  use Gameplatform.DataCase

  alias Gameplatform.Account

  describe "create new user/1" do
    test "creation fails on missing params" do
      params = %{phone_number: "1234567890"}

      assert {:error, %{country_code: ["can't be blank"]}} = Account.create_new_user(params)
    end

    test "creation fails on invalid params" do
      params = %{phone_number: 1_234_567_890, country_code: "+91"}

      assert {:error, %{phone_number: ["is invalid"]}} = Account.create_new_user(params)
    end
  end
end
