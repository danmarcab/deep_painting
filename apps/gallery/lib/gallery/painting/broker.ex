defmodule Gallery.Painting.Broker do
  @moduledoc """
  This module provides a server that listen and makes http calls to start a painting in studio
  """

  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, %{}}
  end

  def start_painting(%Painting{} = painting) do
    GenServer.cast(__MODULE__, {:start_painting, painting})
  end

  def handle_cast({:start_painting, painting}, state) do
    spawn(fn ->
      try_send_data(painting, 5)
    end)

    {:noreply, state}
  end

  defp try_send_data(painting, 0) do
    Logger.error("Giving up starting #{painting.name}")
  end
  defp try_send_data(painting, retries) when retries > 0 do
    case send_data(painting) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Gallery.save_painting(Painting.start(painting))
      e ->
        Logger.error(inspect e)
        try_send_data(painting, retries - 1)
    end
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
      Logger.info "Sending request to studio on: #{paint_url()}"
      Logger.info "Body: #{inspect multipart}"

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
    Gallery.external_url <> "/api/painting/" <> URI.encode(name) <> "/iteration"
  end
end
