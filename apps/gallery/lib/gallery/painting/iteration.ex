defmodule Gallery.Painting.Iteration do
  @moduledoc """
  Module to represent a iteration of a painting.
  """

  defstruct file_name: nil, loss: nil

  @type t :: %__MODULE__{}

  @doc """
  Creates a iteration.
  """
  @spec new(file_name :: String.t, loss :: float) :: t
  def new(file_name, loss), do: %__MODULE__{file_name: file_name, loss: loss}
end
