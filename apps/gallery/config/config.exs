# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :gallery,
  namespace: Gallery

# Configures the endpoint
config :gallery, Gallery.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6MeWLH8/5Mq1BqrlcYv7msdJlS7c4Nyn5ZmWBLVSDKJTw7gOtHY6HqvXNYCd7ANI",
  render_errors: [view: Gallery.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Gallery.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :gallery, :painting_storage,
  type: Painting.Storage.Disk,
  name: :gallery_storage

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
