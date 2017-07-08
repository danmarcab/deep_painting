use Mix.Config

config :studio, painter: Studio.Painter.Pycasso
config :studio, pycasso_path: System.get_env("PYCASSO_PATH")
config :studio, web_port: 4001
