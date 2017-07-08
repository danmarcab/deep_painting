defmodule Gallery.Painting.Storage.Dets do
  use GenServer

  @behaviour Gallery.Painting.Storage

  def supervise?() do
    false
  end

  def start() do
    :dets.open_file(__MODULE__, [type: :set, file: String.to_char_list(file_name)])
    :ok
  end

  def save(painting) do
    :dets.insert(__MODULE__, {painting.name, painting})
    :ok
  end

  def find(name) do
    resp = :dets.lookup(__MODULE__, name)

    case resp do
      [{^name, painting}] -> {:ok, painting}
      _ -> :error
    end
  end

  def all() do
    paintings = :dets.match(__MODULE__, :"$1")

    paintings
    |> List.flatten
    |> Enum.into %{}
  end

  def exists?(name) do
    resp = :dets.lookup(__MODULE__, name)

    case resp do
      [{^name, painting}] -> true
      _ -> false
    end
  end

  def clear() do
    :dets.delete_all_objects(__MODULE__)
  end

  defp file_name do
    Application.app_dir(:gallery, "priv") <> "/painting_storage"
  end
end
