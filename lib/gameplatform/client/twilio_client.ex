defmodule Gameplatform.Client.TwilioClient do
  @moduledoc """
  Module to send otp messages to user.
  """
  use Tesla

  require Logger

  @callback send_sms(String.t(), String.t()) :: {:ok, map()} | {:error, any()}

  plug Tesla.Middleware.FollowRedirects
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.JSON, engine: Jason
  plug Tesla.Middleware.BaseUrl, config(:api_url)

  plug Tesla.Middleware.BasicAuth,
    username: config(:twilio_account_sid),
    password: config(:twilio_auth_token)

  plug Tesla.Middleware.Logger

  def send_sms(to_phone, message) do
    body = %{
      "To" => to_phone,
      "Body" => message,
      "MessagingServiceSid" => config(:messaging_service_sid)
    }

    if Mix.env() in [:test, :dev] do
      Logger.error("this should not be printed in test and dev environment")
    else
      :ok
    end

    "/Messages.json"
    |> post(body)
    |> handle_response()
  end

  defp config(key) do
    :gameplatform
    |> Application.get_env(__MODULE__)
    |> Keyword.get(key)
  end

  defp handle_response({:ok, %Tesla.Env{status: 201, body: _body}}),
    do: {:ok, "Request sent sucessfully"}

  defp handle_response({:ok, %Tesla.Env{status: 400, body: %{"code" => 21_604}}}),
    do: {:error, :phone_number_required}

  defp handle_response({:ok, %Tesla.Env{status: 400, body: %{"code" => 21_211}}}),
    do: {:error, :invalid_phone}

  defp handle_response({:ok, response}), do: {:error, response}
  defp handle_response({:error, reason}), do: {:error, reason}
end
