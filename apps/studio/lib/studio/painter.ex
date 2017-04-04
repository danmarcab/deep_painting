defmodule Studio.Painter do
  @moduledoc """
  Module to interact with a painter executable.
  """
  use GenServer
  require Logger

  alias Studio.Painting
  alias Studio.Painting.Iteration

  def start_link(name, opts \\ []) do
    GenServer.start_link(__MODULE__, {name, opts}, opts)
  end

  def init({name, opts}) do
    with {:ok, painting} <- Studio.find_painting(name),
         painting <- Painting.start(painting),
         port <- start_port(painting)
    do
      {:ok, %{port: port, painting: painting, watcher: opts[:watcher]}}
    else
      _ -> {:stop, :error}
    end
  end

  def stop(painter) do
    GenServer.cast(painter, :stop)
  end

  def handle_cast(:stop, %{port: port, painting: painting} = state) do
    Studio.save_painting(Painting.complete(painting))
    Port.close(port)
    {:stop, :normal, state}
  end

  def handle_info({port, {:data, response}}, %{port: port, painting: painting} = state) do
    Logger.debug("received from port:")
    Logger.debug(inspect(response))

    {:ok, iteration} = parse_iteration(response)
    new_painting = Painting.add_iteration(painting, iteration)
    Studio.save_painting(new_painting)

#    set iteration data in painting and save it
    new_state = %{state | painting: new_painting}
    if state.watcher do
      send(state.watcher, {:painter, state.painting.name})
    end

    if keep_painting?(new_state) do
      Port.command(port, "CONT")
      {:noreply, new_state}
    else
      Port.close(port)
      {:stop, :normal, new_state}
    end
  end

  def handle_info({port, {:exit_status, status}}, %{port: port}) do
    :erlang.error({:port_exit, status})
  end

  def handle_info(_, state), do: {:noreply, state}

  defp start_port(painting) do
    painter_module = Application.get_env(:studio, :painter)
    painter_module.start(painting)
  end

  defp keep_painting?(%{painting: painting}) do
    painting.status != :complete
  end

  defp parse_iteration(data) do
    with {:ok, %{"file_name" => file_name, "loss" => loss}} <- Poison.decode(data),
         {loss, ""} <- Float.parse(loss)
    do
      {:ok, Iteration.new(file_name, loss)}
    end
  end

end
