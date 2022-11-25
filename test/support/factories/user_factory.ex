defmodule Gameplatform.Factories.UserFactory do
  @moduledoc """
  This Module defines factories for building
  data for user
  """

  alias Gameplatform.ApiToConfig
  alias Gameplatform.Accounts.Schema.{User, UserProfile, UserWallet, UserWalletTx, ReferralCode}
  alias Gameplatform.Test.Support.Helpers.Helper

  defmacro __using__(_opts) do
    quote do
      def user_factory() do
        now_time = DateTime.utc_now()
        country_code = Helper.get_indian_country_code()
        phone_number = Helper.get_random_mobile_no()
        id = Ecto.UUID.generate()

        %User{
          id: id,
          phone_number: phone_number,
          country_code: country_code,
          inserted_at: now_time,
          updated_at: now_time,
          user_profile: build(:user_profile, %{user_id: id})
        }
      end

      def user_profile_factory do
        now_time = DateTime.utc_now()
        id = Ecto.UUID.generate()
        unique_id = Helper.unique_id()

        %UserProfile{
          id: id,
          unique_id: unique_id,
          phone_number: Helper.get_random_mobile_no(),
          email: sequence(:email, &"email-#{&1}@example.com"),
          first_name: sequence("gandalf"),
          second_name: sequence("wizard"),
          gender: sequence(:role, ["male", "female"]),
          image: nil,
          kyc_status: sequence(:kyc_status, [true, false]),
          inserted_at: now_time,
          updated_at: now_time,
          user_id: nil,
          user_wallets: build_pair(:user_wallet, %{user_profile_id: id})
        }
      end

      def user_wallet_factory do
        now_time = DateTime.utc_now()
        id = Ecto.UUID.generate()

        wallet_1 = ApiToConfig.get_wallet_type_1()
        wallet_2 = ApiToConfig.get_wallet_type_2()

        %UserWallet{
          id: id,
          wallet_type: sequence(:wallet_type, [wallet_1, wallet_2]),
          inserted_at: now_time,
          updated_at: now_time,
          user_profile_id: nil,
          user_wallet_txs: build_list(1, :user_wallet_tx, %{user_wallet_id: id})
        }
      end

      def user_wallet_tx_factory do
        now_time = DateTime.utc_now()
        id = Ecto.UUID.generate()
        meta_tx_id = Ecto.UUID.generate()

        %UserWalletTx{
          id: id,
          meta_tx_id: meta_tx_id,
          amount: Decimal.new(0),
          tx_type: :credit,
          inserted_at: now_time,
          updated_at: now_time,
          user_wallet_id: nil
        }
      end

      def referral_factory do
        now_time = DateTime.utc_now()

        %ReferralCode{
          id: Ecto.UUID.generate(),
          user_profile_id: nil,
          referral_code: "",
          active: true,
          inserted_at: now_time,
          updated_at: now_time
        }
      end
    end
  end
end
