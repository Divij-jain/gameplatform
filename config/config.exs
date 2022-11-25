# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :gameplatform,
  ecto_repos: [Gameplatform.Repo]

config :gameplatform, Gameplatform.Repo,
  migration_primary_key: [name: :id, type: :uuid],
  migration_foreign_key: [column: :id, type: :uuid]

# Configures the endpoint
config :gameplatform, GameplatformWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GameplatformWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Gameplatform.PubSub,
  live_view: [signing_salt: "RJeDErda"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :gameplatform, Gameplatform.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger

# config :logger, :console,
#   format: "$time $metadata[$level] $message\n",
#   metadata: [:request_id]

config :logger, :console,
  format: {LogFormatter, :format},
  metadata: [
    :request_id,
    :pid,
    :trace_id,
    :span_id
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :joken, default_signer: "secret"

config :gameplatform, Gameplatform.Cache.ApiToConfig,
  caching_pool_sup: Gameplatform.Cache.Redis.RedixSupervisor,
  caching_client: Gameplatform.Cache.Redis.RedixClient,
  pool_size: 5

config :gameplatform, Gameplatform.UserNotifier,
  text_client: Gameplatform.UserNotifier.TextMessage

config :gameplatform, Gameplatform.UserNotifier.TextMessage,
  client: Gameplatform.Client.TwilioClient

config :opentelemetry, :resource, service: %{name: "gameplatform"}

config :gameplatform, Gameplatform.ApiToConfig,
  wallet_type_1: "user_wallet",
  wallet_type_2: "promotional_wallet",
  referral_code_length: 8

config :gameplatform, GameplatformWeb.ApiToConfig,
  socket_identifier: "user_socket_",
  channel_prefix: "main_app:user:"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
