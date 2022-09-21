defmodule Gameplatform.Factories.GameFactory do
  @moduledoc """
  This module defines factories for
  building data based data
  """

  alias Gameplatform.Games.Schema.{Banner, Game, GameSku}

  defmacro __using__(_opts) do
    quote do
      def banner_factory do
        now_time = DateTime.utc_now()

        %Banner{
          id: Ecto.UUID.generate(),
          name: sequence("banner"),
          active: true,
          carousel_url: nil,
          display_url: nil,
          inserted_at: now_time,
          updated_at: now_time
        }
      end

      def game_factory do
        now_time = DateTime.utc_now()

        %Game{
          id: Ecto.UUID.generate(),
          name: sequence("game"),
          active: true,
          game_hash: nil,
          app_id: nil,
          image_url: nil,
          gameplay_url: nil,
          play_mode: nil,
          inserted_at: now_time,
          updated_at: now_time,
          game_skus: [build(:game_sku)]
        }
      end

      def game_sku_factory do
        now_time = DateTime.utc_now()

        %GameSku{
          id: Ecto.UUID.generate(),
          sku_name: sequence("game_sku"),
          sku_code: sequence("sku_code"),
          sku_image: sequence("sku_image_url"),
          amount: Decimal.new(0),
          active: true,
          num_players: 2,
          inserted_at: now_time,
          updated_at: now_time,
          game_id: nil
        }
      end
    end
  end
end
