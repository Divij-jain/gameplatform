defmodule Gameplatform.UserNotifier.TextMessage do
  @moduledoc false

  @text_client Application.compile_env(:gameplatform, [__MODULE__, :client])

  def send_text_message_to_user(to_number, body), do: @text_client.send_sms(to_number, body)
end
