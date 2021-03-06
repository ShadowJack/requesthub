# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :requestbin,
  ecto_repos: [Requestbin.Repo]

# Configures the endpoint
config :requestbin, RequestbinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "F2QQ+c2UHNHgK9uMoNh0fedclmGDhw3XYHv0DMJqk1ZGRN2SIo/KTtAZlu1w8kQm",
  render_errors: [view: RequestbinWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Requestbin.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "63b5AYBOl00V9d9Lhk0ibFYgENZkS3OEy+87uV4+Hqo7MyBm9/hWRFQjNB7i84QH"
    ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Use Jason in Ecto and Phoenix
config :ecto, json_library: Jason
config :phoenix, json_library: Jason
config :requestbin, Requestbin.Repo,
  types: Requestbin.PostgresTypes
config :phoenix, :format_encoders, 
  json: Jason

# Use leex for LiveView templates
config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Config authentication
config :requestbin, Requestbin.Users.Guardian,
       issuer: "requestbin",
       secret_key: "El5xi4AMBrM2IeXLAgTm/HbGSIbrNl0rzlyTHYU/9azRRtV1CkHy/cL4kEM93EoX"

# encription library
config :argon2_elixir,
  t_cost: 1,
  m_cost: 14 

# schedule recurring background tasks
config :requestbin, Requestbin.Scheduler,
  global: true,
  jobs: [
    {"@hourly", {Requestbin.Tasks.CleanupExpiredBins, :run, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
