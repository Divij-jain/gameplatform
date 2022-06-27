defmodule Gameplatform.Instrumentation.Instrumenter do
  @moduledoc """
   Setup instrumentations
  """

  alias Gameplatform.Instrumentation.Instrumenters.{Repo, Phoenix, Redix}

  def setup! do
    Repo.setup!()
    Phoenix.setup!()
    Redix.setup!()

    OpentelemetryLoggerMetadata.setup()
  end
end
