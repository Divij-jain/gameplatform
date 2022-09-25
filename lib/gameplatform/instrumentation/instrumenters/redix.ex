defmodule Gameplatform.Instrumentation.Instrumenters.Redix do
  @moduledoc false

  def setup! do
    OpentelemetryRedix.setup()
  end
end
