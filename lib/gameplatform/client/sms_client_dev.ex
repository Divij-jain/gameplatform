defmodule Gameplatform.Client.SmsClientDev do
  @moduledoc """
  twillio alternative for dev environment
  """
  def send_sms(_to_phone, message) do
    IO.inspect("mocking the sms call in dev environement")
    {:ok, message}
  end
end
