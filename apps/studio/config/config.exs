use Mix.Config

config :logger,
  backends: [:console],
  level: :info

config :studio, :painting_storage,
  type: Painting.Storage.Disk,
  name: :studio_storage

import_config "#{Mix.env}.exs"
