defmodule Gameplatform.AccountTest do
  use Gameplatform.DataCase

  alias Gameplatform.Account
  alias Gameplatform.ApiToConfig
  alias Gameplatform.Test.Support.Helpers.Helper
  alias Gameplatform.Accounts.Schema.User

  import Gameplatform.Factory

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
      phone_number = Helper.get_random_mobile_no()
      params = %{phone_number: phone_number, country_code: "+91"}
      {:ok, %User{} = user} = Account.create_new_user(params)
      assert_created_user(user, params)
    end
  end

  describe "get_complete_user/1" do
    setup do
      user = insert(:user)
      {:ok, %{user: user}}
    end

    test "request suceeds", %{user: user} do
      {:ok, db_user} = Account.get_complete_user(user.id)
      assert db_user.user_profile.id == user.user_profile.id
    end

    test "request returns {:ok,nil} on existing entry" do
      {:ok, nil} = Account.get_complete_user(Ecto.UUID.generate())
    end
  end

  describe "add_money_to_wallet/1" do
    setup do
      user = insert(:user)

      [user_wallet | _] = user.user_profile.user_wallets

      attrs = %{
        amount: Decimal.new(5),
        user_wallet_id: user_wallet.id,
        meta_tx_id: Ecto.UUID.generate(),
        tx_type: :credit
      }

      {:ok, %{user_wallet: user_wallet, attrs: attrs}}
    end

    test "request suceeds", %{user_wallet: user_wallet, attrs: attrs} do
      {:ok, tx} = Account.add_money_to_wallet(attrs)

      assert tx.user_wallet_id == user_wallet.id
      assert Decimal.eq?(tx.amount, attrs.amount)
    end

    test "request returns error", %{attrs: attrs} do
      attrs1 = Map.delete(attrs, :tx_type)
      assert {:error, %{tx_type: ["can't be blank"]}} = Account.add_money_to_wallet(attrs1)

      attrs2 = Map.put(attrs, :tx_type, :any)
      assert {:error, %{tx_type: ["is invalid"]}} == Account.add_money_to_wallet(attrs2)

      attrs3 = Map.put(attrs, :user_wallet_id, Ecto.UUID.generate())

      assert {:error, %{user_wallet_id: ["does not exist"]}} ==
               Account.add_money_to_wallet(attrs3)
    end
  end

  describe "deduct_money_from_wallet/1" do
    setup do
      user = insert(:user)
      wallets = user.user_profile.user_wallets

      wallet =
        Enum.find(wallets, fn wallet ->
          wallet.wallet_type == ApiToConfig.get_wallet_type_1()
        end)

      insert(:user_wallet_tx, %{amount: 5, user_wallet_id: wallet.id})

      {:ok, %{wallet_id: wallet.id}}
    end

    test "request ", %{wallet_id: wallet_id} do
      attrs1 = %{
        amount: Decimal.new(-5),
        user_wallet_id: wallet_id,
        meta_tx_id: Ecto.UUID.generate(),
        tx_type: :debit
      }

      assert {:ok, tx} = Account.deduct_money_from_wallet(attrs1)

      assert tx.user_wallet_id == wallet_id

      attrs2 = %{
        amount: Decimal.new(-10),
        user_wallet_id: wallet_id,
        meta_tx_id: Ecto.UUID.generate(),
        tx_type: :debit
      }

      assert {:error, :not_enogh_balance} = Account.deduct_money_from_wallet(attrs2)

      attrs3 = %{
        amount: Decimal.new(-5),
        user_wallet_id: Ecto.UUID.generate(),
        meta_tx_id: Ecto.UUID.generate(),
        tx_type: :debit
      }

      assert {:error, :does_not_exisit} = Account.deduct_money_from_wallet(attrs3)

      attrs4 = %{
        amount: Decimal.new(0),
        user_wallet_id: wallet_id,
        meta_tx_id: Ecto.UUID.generate()
      }

      assert {:error, %{tx_type: ["can't be blank"]}} = Account.deduct_money_from_wallet(attrs4)
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
