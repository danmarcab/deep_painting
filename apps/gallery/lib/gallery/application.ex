defmodule Gallery.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    storage = Application.get_env(:gallery, :storage)

    children = if storage.supervise?() do
      [worker(storage, [])]
    else
      storage.start()
      []
    end
    # Define workers and child supervisors to be supervised
    children =
        children ++ [
          # Start the endpoint when the application starts
          supervisor(Gallery.Web.Endpoint, []),
          # Start your own worker by calling: Gallery.Worker.start_link(arg1, arg2, arg3)
          # worker(Gallery.Worker, [arg1, arg2, arg3]),
        ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gallery.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
