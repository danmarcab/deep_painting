defmodule Studio do
  @moduledoc """
  Studio provides funcions to create, set the settings and start the process to create a painting.
  """

  @doc """
  Creates an empty painting with a given name. Name must be unique.

  ## Examples

      iex> Studio.create_painting("My painting")
      :ok
      iex> Studio.create_painting("My painting")
      {:error, :already_created}

  """
  def create_painting(name) do
    storage().create(name)
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
    storage().add_content(name, content)
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
    storage().add_style(name, style)
  end

  @doc """
  Adds settings to an existing painting with a given name.

  ## Examples

      iex> Studio.create_painting("My painting")
      :ok
      iex> Studio.add_painting_settings("My painting", %{})
      :ok
      iex> Studio.add_painting_settings("Not my painting", %{})
      {:error, :not_created}

  """
  def add_painting_settings(name, settings) do
    storage().add_settings(name, settings)
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
