defmodule Studio.Painter do
  @moduledoc """
  Module to interact with a painter executable.
  """
  use GenServer

  def start_link(name, opts \\ []) do
    GenServer.start_link(__MODULE__, {name, opts}, opts)
  end

  def init({name, opts}) do
    with {:ok, painting} <- Studio.find_painting(name),
         port <- start_port(painting)
    do
      {:ok, %{port: port, painting: painting, max_iterations: opts[:iterations], iterations: 0, watcher: opts[:watcher]}}
    else
      _ -> {:stop, :error}
    end
  end

  def stop(painter) do
    GenServer.cast(painter, :stop)
  end

  def handle_cast(:stop, %{port: port} = state) do
    Port.close(port)
    {:noreply, state}
  end

  def handle_info({port, {:data, response}}, %{port: port} = state) do
#    IO.inspect("received from port:")
#    IO.inspect response
#    iteration = parse_iteration(response)
#    set iteration data in painting and save it
    new_state = %{state | iterations: state.iterations + 1}
    send(state.watcher, {:painter, state.painting.name})

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

  defp keep_painting?(%{iterations: iterations, max_iterations: max_iterations}) do
    iterations <= max_iterations
  end

end
