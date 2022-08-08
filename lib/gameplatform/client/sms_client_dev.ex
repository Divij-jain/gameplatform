defmodule Gameplatform.Client.SmsClientDev do
  @moduledoc """
  twillio alternative for dev environment
  """
  def send_sms(_to_phone, message) do
    {:ok, message}
  end
end
