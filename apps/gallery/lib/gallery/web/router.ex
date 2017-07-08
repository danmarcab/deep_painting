defmodule Gallery.Web.Router do
  use Gallery.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Gallery.Web do
    pipe_through :api

    post "/painting/:name/iteration", PaintingController, :add_iteration
  end
end
