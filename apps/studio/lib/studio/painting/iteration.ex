defmodule Studio.Painting.Iteration do
  @moduledoc """
  Module to represent a iteration of a painting.
  """

  defstruct file_name: nil, loss: nil

  @type t :: %__MODULE__{}

  @doc """
  Creates empty settings.
  """
  @spec new(file_name :: String.t, loss :: Float.t) :: t
  def new(file_name, loss), do: %__MODULE__{file_name: file_name, loss: loss}
end
