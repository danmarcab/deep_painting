defmodule Painting.Storage.Memory do
  @moduledoc """
  Painting.Storage.Memory implements Painting.Storage storing data in memory. Data vanishes after application restarts.
  """
  use GenServer

  @behaviour Painting.Storage

  def start(storage, opts \\ []) do
    :ets.new(storage, [:set, :public, :named_table])
    :ok
  end

  def save(storage, painting) do
    :ets.insert(storage, {painting.name, painting})
    :ok
  end

  def find(storage, painting_name) do
    resp = :ets.lookup(storage, painting_name)

    case resp do
      [{^painting_name, painting}] -> {:ok, painting}
      _ -> :error
    end
  end

  def all(storage) do
    paintings = :ets.match(storage, :"$1")

    paintings
    |> List.flatten
    |> Enum.into %{}
  end

  def exists?(storage, painting_name) do
    resp = :ets.lookup(storage, painting_name)

    case resp do
      [{^painting_name, painting}] -> true
      _ -> false
    end
  end

  def clear(storage) do
    :ets.delete_all_objects(storage)
    :ok
  end

end
