defmodule GameplatformWeb.Utils do
  @moduledoc """
  Common utility module for GameplatformWeb
  """

  @schema_meta_fields [:__meta__, :__cardinality__, :__field__, :__owner__]
  @date_fields [:inserted_at, :updated_at]

  def make_response(status_code, message), do: %{status_code: status_code, message: message}

  def make_response(status_code, message, data),
    do: %{status_code: status_code, message: message, data: data}

  def make_success_response(payload, message \\ ""),
    do: %{status: "OK", message: message, data: payload}

  def make_error_response(message, payload),
    do: %{status: "ERROR", message: message, data: payload}

  def to_json(struct) do
    schema_struct_to_map(struct)
    |> Enum.map(fn {k, v} -> check_json({k, v}) end)
    |> Enum.into(%{})
  end

  defp check_json({k, %Decimal{} = v}), do: {k, v}
  defp check_json({k, v}) when is_list(v), do: {k, Enum.map(v, &to_json/1)}
  defp check_json({k, v}) when is_struct(v) and k not in @date_fields, do: {k, to_json(v)}
  defp check_json({k, v}), do: {k, v}

  defp schema_struct_to_map(struct) do
    struct
    |> Map.from_struct()
    |> Map.drop(@schema_meta_fields ++ @date_fields)
  end
end
