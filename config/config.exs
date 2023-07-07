# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :drops,
  ecto_repos: [Drops.Repo]

# Configures the endpoint
config :drops, DropsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XjFY2RUeUM5jKnPrpbkvZCuh85cBEgsV5DPzIjFOTOR1t0INWaQYqB53D3XtmlOw",
  render_errors: [view: DropsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Drops.PubSub,
  live_view: [signing_salt: "1j8NZgI3"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

## ExAws Config (optional)

config :ex_aws,
  access_key_id: [{:system, "DROPS_S3_KEY_ID"}],
  secret_access_key: [{:system, "DROPS_S3_SECRET_KEY"}],
  http_client: ExAws.Request.Finch

config :ex_aws, ExAws.Request.Finch, finch: Drops.Finch

config :drops, s3_bucket: "ex-warp-drive"

## End ExAws Config

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
