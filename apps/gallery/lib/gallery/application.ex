defmodule Gallery.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Start painting storage
    storage_config = Application.get_env(:gallery, :painting_storage)
    :ok = storage_config[:type].start(storage_config[:name])

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Gallery.Web.Endpoint, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gallery.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
