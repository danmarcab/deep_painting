defmodule Studio.Painting.Storage.Memory do
  use GenServer

  @behaviour Studio.Painting.Storage

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, %{}}
  end

  def save(painting) do
    GenServer.call(__MODULE__, {:save, painting})
  end

  def find(name) do
    GenServer.call(__MODULE__, {:find, name})
  end

  def exists?(name) do
    GenServer.call(__MODULE__, {:exists?, name})
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  def handle_call({:save, painting}, _from, state) do
    {:reply, :ok, Map.put(state, painting.name, painting)}
  end

  def handle_call({:find, name}, _from, state) do
    {:reply, Map.fetch(state, name), state}
  end

  def handle_call({:exists?, name}, _from, state) do
    {:reply, Map.has_key?(state, name), state}
  end

  def handle_call(:clear, _from, _state) do
    {:reply, :ok, %{}}
  end
end
