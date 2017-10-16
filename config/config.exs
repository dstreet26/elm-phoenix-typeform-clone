# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :typeform_clone,
  ecto_repos: [TypeformClone.Repo]

# Configures the endpoint
config :typeform_clone, TypeformCloneWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Vx9rKwzh0RMhNUtsYVxnN+opygkRr+BEOQXydDtM1uvYbTtTLpP+3BfgM1hJWO0P",
  render_errors: [view: TypeformCloneWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TypeformClone.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
