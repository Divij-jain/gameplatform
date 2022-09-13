defmodule Gameplatform.Auth do
  @moduledoc """
  Module to perform auth operations for user.
  """
  alias Gameplatform.Auth.Otp
  alias Gameplatform.Cache
  alias Gameplatform.UserNotifier
  alias Gameplatform.ApiSpec.Schema.{GetOtpRequest, SubmitOtpRequest}

  @otp_expiry 60

  @doc """
  sends otp text message to user
  """
  @spec send_otp_to_user(GetOtpRequest.t()) :: any()
  def send_otp_to_user(params) do
    to_number = get_user_phone_number(params)

    case maybe_sent_otp_to_user(to_number) do
      {:ok, _body} = response ->
        response

      error ->
        handle_error(error)
    end
  end

  @doc """
  Verify otp submitted by client
  """
  @spec verify_otp(SubmitOtpRequest.t()) ::
          {:ok, true} | {:error, status_code :: number(), reason :: String.t()}
  def verify_otp(params) do
    to_number = get_user_phone_number(params)
    otp = params.otp

    with {:ok, code} when code != nil <- check_for_an_existing_otp(to_number),
         true <- otp == code do
      {:ok, true}
    else
      {:ok, nil} ->
        {:error, 400, "OTP Expired try sending a new one"}

      false ->
        {:error, 400, "Invalid OTP try again"}

      {:error, _} ->
        {:error, 500, "Internal Server Error"}
    end
  end

  defp maybe_sent_otp_to_user(to_number) do
    with {:ok, nil} <- check_for_an_existing_otp(to_number),
         code <- Otp.generate_new_otp(),
         {:ok, "OK"} <- set_otp_in_redis(to_number, code, @otp_expiry) do
      send_message_to_user(to_number, code)
    else
      {:ok, code} ->
        send_message_to_user(to_number, code)

      error ->
        error
    end
  end

  defp get_user_phone_number(params) do
    mobile_number = params.phone_number
    country_code = params.country_code
    "#{country_code}#{mobile_number}"
  end

  defp check_for_an_existing_otp(key) do
    Cache.get_value_from_cache(key)
  end

  defp set_otp_in_redis(key, value, expiry_time),
    do: Cache.set_key_in_cache(key, value, expiry_time)

  defp send_message_to_user(to_number, code) do
    body = create_body(code)
    UserNotifier.send_text_message_to_user(to_number, body)
  end

  defp create_body(code) do
    "OTP for verification is #{code}"
  end

  defp handle_error(response) do
    case response do
      {:error, error} when error in [:phone_number_required, :invalid_phone] ->
        {:error, 400, error}

      {:error, _e} ->
        {:error, 500, "Internal Server error"}
    end
  end
end
