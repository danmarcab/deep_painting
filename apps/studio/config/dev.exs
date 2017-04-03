use Mix.Config

config :studio, storage: Studio.Painting.Storage.Memory
config :studio, painter: Studio.Painter.Pycasso
config :studio, pycasso_path: System.get_env("PYCASSO_PATH")
