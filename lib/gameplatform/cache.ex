defmodule Gameplatform.Cache do
  @moduledoc false
  alias Gameplatform.Cache.ApiToConfig

  @serv ApiToConfig.get_caching_client()

  defdelegate set_key_in_cache(key, value), to: @serv

  defdelegate set_key_in_cache(key, value, expiry), to: @serv

  defdelegate get_value_from_cache(key), to: @serv

  defdelegate delete_value_from_cache(key), to: @serv
end
