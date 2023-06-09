defmodule Gameplatform.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  alias Gameplatform.Cache.ApiToConfig
  use Application

  @impl true
  def start(_type, _args) do
    caching_supervisor = ApiToConfig.get_caching_service()

    Gameplatform.Instrumentation.Instrumenter.setup!()

    children = [
      # Start the Ecto repository
      Gameplatform.Repo,
      # Start the Telemetry supervisor
      GameplatformWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Gameplatform.PubSub},
      # Start the Endpoint (http/https)
      GameplatformWeb.Endpoint,
      # Redix pool supervisor
      caching_supervisor,
      # QueueSupervisor
      {Gameplatform.GameQueue.QueueSupervisor, []},
      # starting user registry
      {Registry, keys: :unique, name: Gameplatform.UserRegistry},
      # Start the user process supervisor
      Gameplatform.Users.UserSupervisor,
      # starting game registry
      {Registry, keys: :unique, name: Gameplatform.GameRegistry},
      {Gameplatform.Runtime.GameSupervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gameplatform.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GameplatformWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
