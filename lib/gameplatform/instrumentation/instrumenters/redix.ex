defmodule Gameplatform.Instrumentation.Instrumenters.Redix do
  def setup! do
    OpentelemetryRedix.setup()
  end
end
