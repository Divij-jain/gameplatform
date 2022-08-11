defmodule GameplatformWeb.Utils do
  @moduledoc """
  Common utility module for GameplatformWeb
  """

  @schema_meta_fields [:__meta__]

  def make_response(status_code, message), do: %{status_code: status_code, message: message}

  def make_response(status_code, message, data),
    do: %{status_code: status_code, message: message, data: data}

  def schema_struct_to_map(struct) do
    struct
    |> Map.from_struct()
    |> Map.drop(@schema_meta_fields)
  end
end
