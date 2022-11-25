defmodule Gameplatform.Repo.Migrations.CreateUserProfileTable do
  use Ecto.Migration

  def up do
    create_user_profile_table()
    create_user_wallet_table()

    create_user_wallet_tx_table()
  end

  def down do
    drop_if_exists table("user_wallet_txs")
    drop_if_exists table("user_wallets")
    drop_if_exists table("user_profiles")
  end

  defp create_user_profile_table do
    create_if_not_exists table("user_profiles") do
      add :user_id, references("users"), null: false
      add :unique_id, :serial, null: false
      add :phone_number, :string, null: false
      add :email, :string
      add :first_name, :string
      add :second_name, :string
      add :gender, :string
      add :image, :string
      add :kyc_status, :boolean, default: false

      timestamps(
        type: :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end

    create unique_index("user_profiles", :user_id)
  end

  defp create_user_wallet_table do
    create_if_not_exists table("user_wallets") do
      add :user_profile_id, references("user_profiles"), null: false
      add :wallet_type, :string, null: false

      timestamps(
        type: :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end

    create unique_index("user_wallets", [:user_profile_id, :wallet_type])
  end

  defp create_user_wallet_tx_table do
    create_if_not_exists table("user_wallet_txs") do
      add :meta_tx_id, :uuid, null: false
      add :user_wallet_id, references("user_wallets"), null: false
      add :amount, :decimal, default: 0
      add :tx_type, :string, null: false

      timestamps(
        type: :utc_datetime_usec,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end
  end
end
