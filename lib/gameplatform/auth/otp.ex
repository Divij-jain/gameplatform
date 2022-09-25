defmodule Gameplatform.Auth.Otp do
  @moduledoc """
  This module provides all functions neccessary for an OTP code
  """

  @doc """
  Generates a new OTP code

  ## Examples

      iex> Gameplatform.Auth.Otp.generate_new_otp()
      #=> "543211"
  """
  @spec generate_new_otp :: String.t()
  def generate_new_otp do
    NimbleTOTP.secret()
    |> NimbleTOTP.verification_code()
  end
end
