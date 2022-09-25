defmodule GameplatformWeb.ApiToConfig do
  @moduledoc """
    Ths module acts as an API to the config file for Gameplatform keywords/macros
  """

  @compile_config Application.compile_env(:gameplatform, __MODULE__, [])

  def socket_id, do: Keyword.get(@compile_config, :socket_identifier)

  def channel_prefix, do: Keyword.get(@compile_config, :channel_prefix)
end
