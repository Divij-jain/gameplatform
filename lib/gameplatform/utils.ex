defmodule Gameplatform.Utils do
  @moduledoc """
  This module documents utility functions
  """

  alias Gameplatform.ApiToConfig

  def create_referral_code(unique_id) do
    num =
      unique_id
      |> to_string()
      |> String.length()

    referral_code_length = ApiToConfig.get_value()

    digits = referral_code_length - num

    digits =
      if digits >= 0 do
        digits
      else
        abs(digits)
      end

    random_string =
      Enum.reduce(1..digits, "", fn _iter, acc ->
        acc <> get_random_alphabet()
      end)

    random_string <> to_string(unique_id)
  end

  def get_random_alphabet do
    char = :erlang.phash2(DateTime.utc_now(), 26)

    base =
      case :erlang.phash2(DateTime.utc_now(), 2) do
        0 ->
          65

        1 ->
          97
      end

    <<base + char>>
  end
end
