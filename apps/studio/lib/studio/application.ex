defmodule Studio.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    IO.inspect "Startingggggg"

    children = [
      worker(Application.get_env(:studio, :storage), [])
    ]

    opts = [strategy: :one_for_one, name: Studio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
