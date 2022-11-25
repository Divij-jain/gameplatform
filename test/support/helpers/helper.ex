defmodule Gameplatform.Test.Support.Helpers.Helper do
  @moduledoc """
  helper function module
  """

  def get_random_mobile_no() do
    DateTime.utc_now()
    |> :erlang.phash2(900_000_000)
    |> Kernel.+(9_000_000_000)
    |> to_string()
  end

  def unique_id() do
    DateTime.utc_now()
    |> :erlang.phash2(600_000)
    |> Kernel.+(6_000_000)
    |> to_string()
  end

  def get_indian_country_code, do: "+91"
end
