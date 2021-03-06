defmodule Gallery do
  @moduledoc """
  Gallery provides funcions to create, set the settings and start the process to create a painting.
  """
  alias Gallery.Web.Endpoint
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
    storage().find(storage_name(), name)
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
  def all_paintings do
    storage().all(storage_name())
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
    :ok = storage().save(storage_name(), painting)

    painting_to_push = prepare_painting_for_ui(painting)

    IO.puts "broadcasting..."
    :ok = Endpoint.broadcast("painting:" <> painting_to_push.name, "update", painting_to_push)
    :ok = Endpoint.broadcast("gallery", "update", painting_to_push)
    :ok
  end

  def clear_storage do
    storage().clear(storage_name())
  end

  #  TODO: move somewhere
  def prepare_painting_for_ui(painting) do
    Painting.prepend_path(painting, external_url() <> "/paintings/" <> painting.name <> "/")
  end

  defp storage do
    Application.get_env(:gallery, :painting_storage)[:type]
  end

  defp storage_name do
    Application.get_env(:gallery, :painting_storage)[:name]
  end

  def external_url do
    if System.get_env("GALLERY_DONT_EXPOSE_PORT") do
      url = Endpoint.struct_url()
      URI.to_string %{url | port: nil}
    else
      Endpoint.url()
    end
  end
end
