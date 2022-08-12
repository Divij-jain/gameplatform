import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :gameplatform, Gameplatform.Repo,
  username: "nayanjain",
  password: "nayanjain",
  hostname: "localhost",
  database: "gameplatform_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gameplatform, GameplatformWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "GyTfuetqYpgGeoE/zyj5IPJjSbCdF+c9TfNsj0pFHn/JNYCbLV2lTIBiWkNg8CAu",
  server: false

# In test we don't send emails.
config :gameplatform, Gameplatform.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# MY configs

config :gameplatform, Gameplatform.UserNotifier,
  text_client: Gameplatform.UserNotifier.TextMessage

config :gameplatform, Gameplatform.UserNotifier.TextMessage, client: TwilioClientMock

config :joken, default_signer: "VDJvzyKfmsRLy0ZNMvQHMuWjttuTcjNs4Lod0SYd2Rd0RWjuUI89Fvsn2prb9a7T"
