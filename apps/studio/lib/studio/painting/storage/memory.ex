defmodule Studio.Painting.Storage.Memory do
  use GenServer

  @behaviour Studio.Painting.Storage

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, %{}}
  end

  def create(name) do
    GenServer.call(__MODULE__, {:create, name})
  end

  def add_content(name, content) do
    GenServer.call(__MODULE__, {:add_content, name, content})
  end

  def add_style(name, style) do
    GenServer.call(__MODULE__, {:add_style, name, style})
  end

  def add_settings(name, settings) do
    GenServer.call(__MODULE__, {:add_settings, name, settings})
  end

  def has_painting?(name) do
    GenServer.call(__MODULE__, {:has_painting?, name})
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  def handle_call({:create, name}, _from, state) do
    if Map.has_key?(state, name) do
      {:reply, {:error, :already_created}, state}
    else
      {:reply, :ok, Map.put(state, name, %{})}
    end
  end

  def handle_call({:add_content, name, content}, _from, state) do
    if Map.has_key?(state, name) do
      {:reply, :ok, Map.update(state, name, %{}, &Map.put(&1, :content, content))}
    else
      {:reply, {:error, :not_created}, state}
    end
  end

  def handle_call({:add_style, name, style}, _from, state) do
    if Map.has_key?(state, name) do
      {:reply, :ok, Map.update(state, name, %{}, &Map.put(&1, :style, style))}
    else
      {:reply, {:error, :not_created}, state}
    end
  end

  def handle_call({:add_settings, name, settings}, _from, state) do
    if Map.has_key?(state, name) do
      {:reply, :ok, Map.update(state, name, %{}, &Map.put(&1, :settings, settings))}
    else
      {:reply, {:error, :not_created}, state}
    end
  end

  def handle_call({:has_painting?, name}, _from, state) do
    Map.has_key?(state, name)
  end

  def handle_call(:clear, _from, state) do
    {:reply, :ok, %{}}
  end
end
