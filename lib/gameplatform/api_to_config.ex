defmodule Gameplatform.ApiToConfig do
  @moduledoc """
    Ths module acts as an API to the config file for Gameplatform keywords/macros
  """

  @compile_config Application.compile_env(:gameplatform, __MODULE__, [])

  def get_wallet_type_1, do: Keyword.fetch!(@compile_config, :wallet_type_1)

  def get_wallet_type_2, do: Keyword.fetch!(@compile_config, :wallet_type_2)
end
