defmodule Painting do
  @moduledoc """
  Module to create and manipulate Paintings. A painting has a status that can be:

  - :not_ready -> Painting cannot be started, it needs configuration
  - :ready -> Painting can be started, all configuration is set
  - :in_progress -> Painting is in progress.
  - :complete -> Painting is complete.

  To change between :not_ready and ready you need to set content, style and settings.

  ## Examples

      iex> p = Painting.new("my_painting")
      iex> p.status
      :not_ready
      iex> p = Painting.add_content(p, "content.png")
      iex> p.status
      :not_ready
      iex> p = Painting.add_style(p, "style.png")
      iex> p.status
      :not_ready
      iex> p = Painting.add_settings(p, %Settings{})
      iex> p.status
      :ready

  """

  alias Painting.Settings
  alias Painting.Iteration

  defstruct name: nil, content: nil, style: nil, settings: nil, status: :not_ready, iterations: []

  @type t :: %__MODULE__{}

  @doc """
  Creates an painting with a given name

  ## Examples

      iex> p = Painting.new("my_painting")
      iex> p.status
      :not_ready

  """
  @spec new(name :: String.t) :: t
  def new(name), do: %__MODULE__{name: name}

  @doc """
  Adds content to a painting

  ## Examples

      iex> p = Painting.new("my_painting")
      iex> p.content
      nil
      iex> p = Painting.add_content(p, "content.png")
      iex> p.content
      "content.png"

  """
  @spec add_content(painting :: t, content :: String.t) :: t
  def add_content(%__MODULE__{} = p, content) do
    %{p | content: content}
    |> update_status()
  end

  @doc """
  Adds style to a painting

  ## Examples

      iex> p = Painting.new("my_painting")
      iex> p.style
      nil
      iex> p = Painting.add_style(p, "style.png")
      iex> p.style
      "style.png"

  """
  @spec add_style(painting :: t, style :: String.t) :: t
  def add_style(%__MODULE__{} = p, style) do
    %{p | style: style}
    |> update_status()
  end

  @doc """
  Adds settings to a painting

  ## Examples

      iex> p = Painting.new("my_painting")
      iex> p.settings
      nil
      iex> p = Painting.add_settings(p, %Settings{})
      iex> p.settings
      %Settings{}

  """
  @spec add_settings(painting :: t, settings :: Settings.t) :: t
  def add_settings(%__MODULE__{} = p, %Settings{} = settings) do
    %{p | settings: settings}
    |> update_status()
  end

  @doc """
  Adds an iteration to a painting

  ## Examples

      iex> ready_painting().status
      :ready
      iex> Painting.start(ready_painting()).status
      :in_progress

  """
  @spec start(painting :: t) :: t
  def start(%__MODULE__{status: :ready} = p) do
    %{p | status: :in_progress}
  end

  @doc """
  Adds an iteration to a painting

  ## Examples

      iex> in_progress_painting().status
      :in_progress
      iex> Painting.complete(in_progress_painting()).status
      :complete

  """
  @spec complete(painting :: t) :: t
  def complete(%__MODULE__{status: :in_progress} = p) do
    %{p | status: :complete}
  end

  @doc """
  Adds an iteration to a painting

  ## Examples

      iex> p = Painting.new("my_painting")
      iex> p.settings
      nil
      iex> p = Painting.add_settings(p, %Settings{})
      iex> p.settings
      %Settings{}

  """
  @spec add_iteration(painting :: t, iter :: Iteration.t) :: t
  def add_iteration(%__MODULE__{status: :in_progress} = p, %Iteration{} = iter) do
    %{p | iterations: p.iterations ++ [iter]}
    |> update_status()
  end

  def prepend_path(%__MODULE__{content: content, style: style, iterations: iterations} = p, path) do
    %{p |
      content: path <> content,
      style: path <> style,
      iterations: iterations |> Enum.map(fn i -> %{i | file_name: path <> i.file_name} end)
    }
  end

  defp update_status(%__MODULE__{content: nil, status: :not_ready} = p), do: p
  defp update_status(%__MODULE__{style: nil, status: :not_ready} = p), do: p
  defp update_status(%__MODULE__{settings: nil, status: :not_ready} = p), do: p
  defp update_status(%__MODULE__{status: :not_ready} = p), do: %{p | status: :ready}
  defp update_status(%__MODULE__{status: :ready} = p), do: p
  defp update_status(%__MODULE__{status: :in_progress, settings: %Settings{iterations: n_iterations}, iterations: iterations} = p) when length(iterations) <= n_iterations, do: p
  defp update_status(%__MODULE__{status: :in_progress} = p), do: %{p | status: :complete}

end
