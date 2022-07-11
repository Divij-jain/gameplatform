defmodule GameplatformWeb.OpentelemetryPlug do
  alias __MODULE__

  defmodule Propagation do
    @moduledoc """
      Adds Opentelemetry context/trace_id to the plug response
    """

    @behaviour Plug
    import Plug.Conn, only: [register_before_send: 2, merge_resp_headers: 2]

    @impl true
    def init(opts) do
      opts
    end

    @impl true
    def call(conn, _opts) do
      register_before_send(
        conn,
        &merge_resp_headers(&1, OpentelemetryPlug.inject_header_context([]))
      )
    end
  end

  if Code.ensure_loaded(:otel_propagator) do
    if function_exported?(:otel_propagator, :text_map_extract, 1) do
      def inject_header_context(headers) do
        :otel_propagator.text_map_inject(headers)
      end
    else
      def inject_header_context(headers) do
        :otel_propagator_text_map.inject(headers)
      end
    end
  end
end
