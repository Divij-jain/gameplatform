defmodule Gameplatform.Instrumentation.Instrumenters.Repo do
  def setup! do
    OpentelemetryEcto.setup(Gameplatform.Repo.config()[:telemetry_prefix])
  end
end
