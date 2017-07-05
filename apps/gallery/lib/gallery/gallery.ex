defmodule Gallery do
  @moduledoc """
  Gallery provides funcions to create, set the settings and start the process to create a painting.
  """

  alias Gallery.Painting

  @doc """
  Finds an existing painting with a given name.

  ## Examples

      iex> Gallery.create_painting("My painting")
      :ok
      iex> {:ok, %Painting{} = painting} = Gallery.find_painting("My painting")
      iex> painting.name
      "My painting"
      iex> Gallery.find_painting("Not my painting")
      :error

  """
  def find_painting(name) do
    storage().find(name)
  end

  @doc """
  Returns a map with all exisiting paintings (name of the painting as key, Painting as value)

  ## Examples

      iex> Gallery.create_painting("My painting")
      :ok
      iex> Gallery.create_painting("My painting 2")
      :ok
      iex> paintings_map = Gallery.all_paintings()
      iex> Map.keys(paintings_map)
      ["My painting", "My painting 2"]

  """
  def all_paintings() do
    storage().all()
  end

  @doc """
  Saves a painting with a given name.

  ## Examples

      iex> p = %Painting{name: "My painting", content: "my_content"}
      iex> :ok = Gallery.save_painting(p)
      iex> {:ok, %Painting{} = painting} = Gallery.find_painting("My painting")
      iex> {painting.name, painting.content}
      {"My painting", "my_content"}

  """
  def save_painting(painting) do
    :ok = storage().save(painting)
    IO.puts "broadcasting..."
    painting_to_push = Painting.prepend_path(painting, "http://localhost:4000/paintings/" <> painting.name <> "/")
    :ok = Gallery.Web.Endpoint.broadcast("painting:" <> painting_to_push.name, "update", painting_to_push)
    :ok = Gallery.Web.Endpoint.broadcast("gallery", "update", painting_to_push)
    :ok
  end

  defp storage() do
    Application.get_env(:gallery, :storage)
  end

end
