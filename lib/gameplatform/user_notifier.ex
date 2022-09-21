defmodule Gameplatform.UserNotifier do
  @moduledoc false

  @text_client Application.compile_env(:gameplatform, [__MODULE__, :text_client])

  defdelegate send_text_message_to_user(to_number, body), to: @text_client
end
