defmodule Painting.Settings do
  @moduledoc """
  Module to create and manipulate painting settings.
  """

  @derive [Poison.Encoder]
  defstruct iterations: 5, content_weight: nil, style_weight: nil, variation_weight: nil, output_width: 200

  @type t :: %__MODULE__{}

  @doc """
  Creates empty settings.
  """
  @spec new :: t
  def new, do: %__MODULE__{}
end
