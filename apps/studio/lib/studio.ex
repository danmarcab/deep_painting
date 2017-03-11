defmodule Studio do
  @moduledoc """
  Studio provides funcions to create, set the settings and start the process to create a painting.
  """

  alias Studio.Painting

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

  def start_painting(name, iterations) do
    :ok
  end

  def stop_painting(name) do
    :ok
  end

  defp storage() do
    Application.get_env(:studio, :storage)
  end

end
