defmodule Painting.Storage.Disk do
  use GenServer

  @behaviour Painting.Storage

  def start(storage, opts \\ []) do
    file_name = Keyword.get(opts, :file_name,  Application.app_dir(:painting, "priv") <> "/storage/" <> Atom.to_string(storage))
    {:ok, ^storage} = :dets.open_file(storage, [type: :set, file: String.to_char_list(file_name)])
    :ok
  end

  def save(storage, painting) do
    :dets.insert(storage, {painting.name, painting})
    :ok
  end

  def find(storage, painting_name) do
    resp = :dets.lookup(storage, painting_name)

    case resp do
      [{^painting_name, painting}] -> {:ok, painting}
      _ -> :error
    end
  end

  def all(storage) do
    paintings = :dets.match(storage, :"$1")

    paintings
    |> List.flatten
    |> Enum.into %{}
  end

  def exists?(storage, painting_name) do
    resp = :dets.lookup(storage, painting_name)

    case resp do
      [{^painting_name, painting}] -> true
      _ -> false
    end
  end

  def clear(storage) do
    :dets.delete_all_objects(storage)
    :ok
  end
end
