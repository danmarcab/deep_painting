defmodule Gallery.Painting.Storage.Ets do
  use GenServer

  @behaviour Gallery.Painting.Storage

  def supervise?() do
    false
  end

  def start() do
    :ets.new(__MODULE__, [:set, :public, :named_table])
    :ok
  end

  def save(painting) do
    :ets.insert(__MODULE__, {painting.name, painting})
    :ok
  end

  def find(name) do
    resp = :ets.lookup(__MODULE__, name)

    case resp do
      [{^name, painting}] -> {:ok, painting}
      _ -> :error
    end
  end

  def all() do
    paintings = :ets.match(__MODULE__, :"$1")

    paintings
    |> List.flatten
    |> Enum.into %{}
  end

  def exists?(name) do
    resp = :ets.lookup(__MODULE__, name)

    case resp do
      [{^name, painting}] -> true
      _ -> false
    end
  end

  def clear() do
    :ets.delete_all_objects(__MODULE__)
  end

end
