defmodule Gallery.Web.Router do
  use Gallery.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Gallery.Web do
    pipe_through :api
  end
end
