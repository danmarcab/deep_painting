defmodule Gallery.Painting.Broker do
  @moduledoc """
  This module provides a server that listens to messages of type:
    {:painter, painting_name, %Painting.Iteration{} = iteration}
  And makes requests back to gallery with the information of the iteration.
  """

  use GenServer

  alias Gallery.Web.Endpoint
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, nil}
  end

  def start_painting(%Painting{} = painting) do
    GenServer.cast(__MODULE__, {:start_painting, painting})
  end

  def handle_cast({:start_painting, painting}, state) do
    case send_data(painting) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Gallery.save_painting(Painting.start(painting))
      e ->
        Logger.error (inspect e)
    end

    {:noreply, state}
  end

  defp send_data(%Painting{} = painting) do
    multipart =
      {
        :multipart,
        [
          {"name", painting.name},
          multipart_file(painting.name, "content", painting.content),
          multipart_file(painting.name, "style", painting.style),
          {"settings", Poison.encode!(painting.settings)},
          {"callback_url", callback_url(painting.name)}
        ]
      }

    try do
      HTTPoison.post(paint_url(), multipart)
    rescue
      error ->
        error
    end
  end

  defp multipart_file(painting_name, name, file_name) do
    file_on_disk = painting_path(painting_name) <> file_name

    {:file, file_on_disk, {"form-data", [{"name", name}, {"filename", file_name}]}, []}
  end

  defp painting_path(name) do
    Application.app_dir(:gallery, "priv") <> "/static/paintings/" <> name <> "/"
  end

  defp paint_url do
    host = System.get_env("STUDIO_HOST")
    host = if System.get_env("STUDIO_PORT") do
      host <> ":" <> System.get_env("STUDIO_PORT")
    end
    host <> "/paint/"
  end

  defp callback_url(name) do
    Endpoint.url() <> "/api/painting/" <> URI.encode(name) <> "/iteration"
  end
end
