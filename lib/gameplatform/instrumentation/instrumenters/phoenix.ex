defmodule Gameplatform.Instrumentation.Instrumenters.Phoenix do
  def setup! do
    OpentelemetryPhoenix.setup()
  end
end
