defmodule Studio.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Application.get_env(:studio, :storage), []),
      supervisor(Registry, [:unique, Studio.Painter]),
      Plug.Adapters.Cowboy.child_spec(:http, Studio.Web.Router, [], [port: Application.get_env(:studio, :web_port)])
    ]

    opts = [strategy: :one_for_one, name: Studio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
