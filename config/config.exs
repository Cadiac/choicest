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
  secret_key_base: "W6UvY6YOBz7ejHtimZWzip9MYqj0Wy50Sejmi4gZgfpYqb7cCYF6pBXo5r+hVm+O",
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
