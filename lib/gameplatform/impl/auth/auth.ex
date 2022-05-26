defmodule Gameplatform.Impl.Auth.Auth do
  alias GamePlatform.RedixSupervisor

  def send_otp_to_user(params) do
    mobile_number = Map.get(params, "phone_number")
    country_code = Map.get(params, "country_code")
    to_number = "#{country_code}#{mobile_number}"

    case maybe_sent_otp_to_client(to_number) do
      {:ok, _body} = response ->
        response

      error ->
        handle_error(error)
    end
  end

  def verify_otp(params) do
    mobile_number = Map.get(params, "phone_number")
    country_code = Map.get(params, "country_code")
    to_number = "#{country_code}#{mobile_number}"
    otp = Map.get(params, "otp")

    case check_for_an_existing_otp(to_number) do
      {:ok, code} when code != nil ->
        otp == code

      {:ok, nil} ->
        {:error, 400, "OTP Expired try sending a new one"}

      _error ->
        {:error, 500, "Internal Server Error"}
    end
  end

  defp check_for_an_existing_otp(key), do: RedixSupervisor.command(["GET", key])

  defp set_otp_in_redis(key, value, expiry_time),
    do: RedixSupervisor.command(["SETEX", key, expiry_time, value])

  # defp delete_otp_from_redis(key) do
  #   RedixSupervisor.command(["DEL", key])
  # end

  defp generate_new_otp() do
    NimbleTOTP.secret()
    |> NimbleTOTP.verification_code()
  end

  defp create_body(code) do
    "Your verification code for Platform is #{code}"
  end

  defp send_message_to_client(to_number, code) do
    body = create_body(code)
    Gameplatform.Client.TwilioClient.send_sms(to_number, body)
  end

  defp maybe_sent_otp_to_client(to_number) do
    case check_for_an_existing_otp(to_number) do
      {:ok, nil} ->
        code = generate_new_otp()

        case set_otp_in_redis(to_number, code, 60) do
          {:ok, "OK"} ->
            send_message_to_client(to_number, code)

          error ->
            error
        end

      {:ok, code} ->
        send_message_to_client(to_number, code)

      error ->
        error
    end
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
