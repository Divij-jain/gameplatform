defmodule Gameplatform.Repo.Migrations.ReferralTable do
  use Ecto.Migration

  def up do
    create table("referrals") do
      add :user_profile_id, references("user_profiles"), null: false
      add :referral_code, :string, unique: true
      add :active, :boolean, default: true

      timestamps(
        type: :utc_datetime,
        default: fragment("timezone('utc', now())"),
        null: false
      )
    end

    create unique_index("referrals", [:referral_code])
  end

  def down do
    drop_if_exists table("referrals")
  end
end
