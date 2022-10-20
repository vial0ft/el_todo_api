# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :el_todo_api,
  generators: [binary_id: true]

# Configures the endpoint
config :el_todo_api, ElTodoApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ElTodoApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ElTodoApi.PubSub,
  live_view: [signing_salt: "77He8JKo"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

#swagger config
config :phoenix_swagger, json_library: Jason

config :el_todo_api, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: ElTodoApiWeb.Router,
      endpoint: ElTodoApiWeb.Endpoint
    ]
  }

# Guardian config
config :el_todo_api, ElTodoApi.Guardian,
 issuer: "el_auth_service",
 secret_key: "secret"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
