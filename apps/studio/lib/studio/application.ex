defmodule Studio.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Start painting storage
    storage_config = Application.get_env(:studio, :painting_storage)
    :ok = storage_config[:type].start(storage_config[:name])

    port = if System.get_env("STUDIO_PORT") do
      String.to_integer(System.get_env("STUDIO_PORT"))
    else
      Application.get_env(:studio, :web_port)
    end

    children = [
      worker(Studio.Painting.Broker, []),
      supervisor(Registry, [:unique, Studio.Painter]),
      Plug.Adapters.Cowboy.child_spec(:http, Studio.Web.Router, [], [port: port])
    ]

    opts = [strategy: :one_for_one, name: Studio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
