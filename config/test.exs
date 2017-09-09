use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :choicest, ChoicestWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :choicest, Choicest.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "choicest_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce password hashing rounds for faster tests
config :argon2_elixir,
  t_cost: 2,
  m_cost: 12
