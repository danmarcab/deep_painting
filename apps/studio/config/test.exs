use Mix.Config

config :studio, painter: Studio.Painter.TestPycasso
config :studio, web_port: 4002

config :studio, :painting_storage,
  type: Painting.Storage.Memory,
  name: :studio_storage
