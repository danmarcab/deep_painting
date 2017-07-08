defmodule Studio.Painting.Broker do
  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, nil}
  end

  def handle_info({:painter, painting_name, %Painting.Iteration{} = iteration}, state) when is_binary(painting_name) do
    spawn(fn ->
      case notify(painting_name, iteration) do
        {:ok, %HTTPoison.Response{status_code: 200}} ->
          :ok
        error ->
          Logger.error (inspect error)
      end
    end)

    {:noreply, state}
  end

  defp notify(painting_name, %Painting.Iteration{} = iteration) when is_binary(painting_name) do
    multipart = {:multipart, [{"loss", Float.to_string(iteration.loss)}, multipart_file("file", iteration.file_name)]}

    headers = [{"Accept", "Application/json; Charset=utf-8"}]

    try do
      HTTPoison.post(gallery_url(painting_name), multipart, headers)
    rescue
      error ->
        error
    end
  end

  def multipart_file(name, file_name) do
    {:file, file_name, {"form-data", [{"name", name}, {"filename", Path.basename file_name}]}, []}
  end

  defp gallery_url(name) do
    "localhost:4000/api/painting/" <> name <> "/iteration"
  end
end
