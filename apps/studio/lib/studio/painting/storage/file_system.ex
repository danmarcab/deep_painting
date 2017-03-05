defmodule Studio.Painting.Storage.FileSystem do
  @behaviour Studio.Painting.Storage

  def start_link() do
    :ignore
  end

  def create(name) do
    :ok
  end

  def add_content(name, content) do
    :ok
  end

  def add_style(name, style) do
    :ok
  end

  def has_painting?(name) do
    true
  end
end
