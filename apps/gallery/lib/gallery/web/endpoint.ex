defmodule Gallery.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :gallery

  socket "/socket", Gallery.Web.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :gallery, gzip: false,
    only: ~w(index.html elm.js style.css css fonts images js paintings favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_gallery_key",
    signing_salt: "MluJuPi0"

  plug Gallery.Web.Router

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    port = System.get_env("GALLERY_PORT") || raise "expected the GALLERY_PORT environment variable to be set"
    host = System.get_env("GALLERY_HOST") || raise "expected the GALLERY_HOST environment variable to be set"

    new_config =
      config
      |> Keyword.put(:http, [:inet6, port: port])
      |> Keyword.update(:url, [host: host, port: port], fn(url_config) ->
          url_config
          |> Keyword.put(:host, host)
          |> Keyword.put(:port, port)
        end)

    {:ok, new_config}
  end
end
