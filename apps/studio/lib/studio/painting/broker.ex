defmodule Studio.Painting.Broker do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, nil}
  end

  def handle_info({:painter, painting_name, iteration}, state) do
    spawn(fn ->
      {:ok, %HTTPoison.Response{status_code: 200}} = notify(painting_name, iteration)
    end)

    {:noreply, state}
  end

  def notify(painting_name, iteration) do
    multipart = {:multipart, [{"loss", Float.to_string(iteration.loss)}, multipart_file("file", iteration.file_name)]}
    |> IO.inspect

    headers = ["Accept": "Application/json; Charset=utf-8"]
    HTTPoison.post(gallery_url(painting_name), multipart, headers)
  end

  def multipart_file(name, file_name) do
    {:file, file_name, { "form-data", [{"name", name}, {"filename", Path.basename file_name}]}, []}
  end

  def gallery_url(name) do
    "localhost:4000/api/painting/" <> name <> "/iteration"
  end
end
