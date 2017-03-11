defmodule Studio.Painting.Settings do
  @moduledoc """
  Module to create and manipulate painting settings.
  """

  defstruct content_weight: nil

  @type t :: %__MODULE__{}

  @doc """
  Creates empty settings.
  """
  @spec new() :: t
  def new(), do: %__MODULE__{}
end
