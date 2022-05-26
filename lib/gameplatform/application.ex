defmodule Gameplatform.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # isolated_children = [
    #   {Redix, sync_connect: true, exit_on_disconnection: true},
    #   MyApp.MyGenServer
    # ]

    # isolated_supervisor = %{
    #   id: MyChildSupervisor,
    #   type: :supervisor,
    #   start: {Supervisor, :start_link, [isolated_children, [strategy: :rest_for_one]]},
    # }

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
      GamePlatform.RedixSupervisor
      # isolated_supervisor
      # Start a worker by calling: Gameplatform.Worker.start_link(arg)
      # {Gameplatform.Worker, arg}
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
