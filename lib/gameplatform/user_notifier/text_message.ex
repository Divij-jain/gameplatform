defmodule Gameplatform.UserNotifier.TextMessage do
  alias Gameplatform.Client.TwilioClient

  def send_text_message_to_user(to_number, body) do
    TwilioClient.send_sms(to_number, body)
  end
end
