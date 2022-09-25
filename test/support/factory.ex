defmodule Gameplatform.Factory do
  @moduledoc """
  Factory module which contains all other factories
  """

  use ExMachina.Ecto, repo: Gameplatform.Repo
  use Gameplatform.Factories.UserFactory
  use Gameplatform.Factories.GameFactory
end
