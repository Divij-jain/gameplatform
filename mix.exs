defmodule Gameplatform.MixProject do
  use Mix.Project

  def project do
    [
      app: :gameplatform,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Gameplatform.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  # originial
  # defp elixirc_paths(_), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test/support"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.7"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:tesla, "~> 1.4.0"},
      {:mox, "~> 1.0", only: :test},
      {:mimic, "~> 1.7", only: :test},
      {:redix, "~> 1.1"},
      {:nimble_totp, "~> 0.1.0"},
      {:joken, "~> 2.4"},
      {:open_api_spex, "~> 3.11"},
      {:log_formatter, git: "git@github.com:divijjain/log_formatter.git", tag: "v1.0.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      # opentelemetry sdk
      {:opentelemetry, "~> 1.0.0-rc.2"},
      # exporter
      {:opentelemetry_exporter, "~> 1.0.0-rc"},
      # api for
      {:opentelemetry_ecto, "~> 1.0.0-rc"},
      {:opentelemetry_phoenix, "~> 1.0.0-rc"},
      {:opentelemetry_logger_metadata, "~> 0.1.0-rc"},
      {:opentelemetry_redix, "~> 0.1"},
      # exmachina for factories
      {:ex_machina, "~> 2.7.0"},
      {:telemetry_metrics_statsd, "~> 0.6.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"],
      spec: ["openapi.spec.json  --spec GameplatformWeb.ApiSpec \"priv/static/swagger.json\""]
    ]
  end
end
