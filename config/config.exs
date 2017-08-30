# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :choicest,
  ecto_repos: [Choicest.Repo]

# Configures the endpoint
config :choicest, ChoicestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  render_errors: [view: ChoicestWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Choicest.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  region: System.get_env("AWS_REGION")

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Choicest",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: Map.fetch!(System.get_env(), "GUARDIAN_SECRET_KEY"),
  serializer: Choicest.GuardianSerializer
