defmodule Studio.Painting.Broker do
  @moduledoc """
  This module provides a server that listens to messages of type:
    {:painter, painting_name, %Painting.Iteration{} = iteration}
  And makes requests back to gallery with the information of the iteration.
  """

  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, nil}
  end

  def handle_info({:painter, callback_url, painting_name, %Painting.Iteration{} = iteration}, state) when is_binary(painting_name) do
    spawn(fn ->
      case notify(callback_url, painting_name, iteration) do
        {:ok, %HTTPoison.Response{status_code: 200}} ->
          :ok
        error ->
          Logger.error (inspect error)
      end
    end)

    {:noreply, state}
  end

  defp notify(callback_url, painting_name, %Painting.Iteration{} = iteration) when is_binary(painting_name) do
    multipart = {:multipart, [{"loss", Float.to_string(iteration.loss)}, multipart_file("file", iteration.file_name)]}

    headers = [{"Accept", "Application/json; Charset=utf-8"}]

    try do
      HTTPoison.post(callback_url, multipart, headers)
    rescue
      error ->
        error
    end
  end

  def multipart_file(name, file_name) do
    {:file, file_name, {"form-data", [{"name", name}, {"filename", Path.basename file_name}]}, []}
  end
end
