defmodule Gameplatform.UserNotifier do

  @compile_config Application.compile_env(:gameplatform, __MODULE__)

  defdelegate send_text_message_to_user(to_number, body),
    to: Keyword.fetch!(@compile_config, :text_client)
end
