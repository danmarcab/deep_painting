defmodule Studio do
  @moduledoc """
  Studio provides funcions to create, set the settings and start the process to create a painting.
  """

  alias Studio.Painting
  alias Studio.Painter

  @doc """
  Creates an empty painting with a given name. Name must be unique.

  ## Examples

      iex> Studio.create_painting("My painting")
      :ok
      iex> Studio.create_painting("My painting")
      {:error, :already_created}

  """
  def create_painting(name) do
    if storage().exists?(name) do
      {:error, :already_created}
    else
      storage().save(Painting.new(name))
    end
  end

  @doc """
  Adds content to an existing painting with a given name.

  ## Examples

      iex> Studio.create_painting("My painting")
      :ok
      iex> Studio.add_painting_content("My painting", "img/content.png")
      :ok
      iex> Studio.add_painting_content("Not my painting", "img/content.png")
      {:error, :not_created}

  """
  def add_painting_content(name, content) do
    if storage().exists?(name) do
      {:ok, painting} = storage().find(name)
      storage().save(Painting.add_content(painting, content))
    else
      {:error, :not_created}
    end
  end

  @doc """
  Adds style to an existing painting with a given name.

  ## Examples

      iex> Studio.create_painting("My painting")
      :ok
      iex> Studio.add_painting_style("My painting", "img/style.png")
      :ok
      iex> Studio.add_painting_style("Not my painting", "img/style.png")
      {:error, :not_created}

  """
  def add_painting_style(name, style) do
    if storage().exists?(name) do
      {:ok, painting} = storage().find(name)
      storage().save(Painting.add_style(painting, style))
    else
      {:error, :not_created}
    end
  end

  @doc """
  Adds settings to an existing painting with a given name.

  ## Examples

      iex> Studio.create_painting("My painting")
      :ok
      iex> Studio.add_painting_settings("My painting", Painting.Settings.new())
      :ok
      iex> Studio.add_painting_settings("Not my painting", Painting.Settings.new())
      {:error, :not_created}

  """
  def add_painting_settings(name, %Painting.Settings{} = settings) do
    if storage().exists?(name) do
      {:ok, painting} = storage().find(name)
      storage().save(Painting.add_settings(painting, settings))
    else
      {:error, :not_created}
    end
  end

  @doc """
  Finds an existing painting with a given name.

  ## Examples

      iex> Studio.create_painting("My painting")
      :ok
      iex> {:ok, %Painting{} = painting} = Studio.find_painting("My painting")
      iex> painting.name
      "My painting"
      iex> Studio.find_painting("Not my painting")
      :error

  """
  def find_painting(name) do
    storage().find(name)
  end

  @doc """
  Saves a painting with a given name.

  ## Examples

      iex> p = %Painting{name: "My painting", content: "my_content"}
      iex> :ok = Studio.save_painting(p)
      iex> {:ok, %Painting{} = painting} = Studio.find_painting("My painting")
      iex> {painting.name, painting.content}
      {"My painting", "my_content"}

  """
  def save_painting(painting) do
    storage().save(painting)
  end

  # TODO: add doc/tests
  def start_painting(name) do
    Painter.start_link(name, name: painter_name(name), watcher: Studio.Painting.Broker)
  end

  # TODO: add doc/tests
  def stop_painting(name) do
    Painter.stop(painter_name(name))
  end

  defp storage() do
    Application.get_env(:studio, :storage)
  end

  defp painter_name(painting_name) do
    {:via, Registry, {Studio.Painter, painting_name}}
  end
end
