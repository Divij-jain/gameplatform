defmodule Gameplatform.Auth.Otp do
  def generate_new_otp() do
    NimbleTOTP.secret()
    |> NimbleTOTP.verification_code()
  end
end
