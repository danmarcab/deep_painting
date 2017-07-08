defmodule Painting.Storage do
  @moduledoc """
  Painting.Storage defines the contract to store/retrive paintings
  """

  @doc """
  Starts storage
  """
  @callback start(storage :: atom, opts :: Keyword.t) :: :ok | :error

  @doc """
  Finds a return a painting by name.
  """
  @callback find(storage :: atom, name :: String.t) :: {:ok, Painting.t} | :error

  @doc """
  Return a map with all paintings on the storage.
  """
  @callback all(storage :: atom) :: %{optional(String.t) => Painting.t}


  @doc """
  Check if a painting with a given name exists.
  """
  @callback exists?(storage :: atom, name :: String.t) :: boolean

  @doc """
  Save a painting in the storage. If a painting with the same name exists, it will update it.
  """
  @callback save(storage :: atom, Painting.t) :: :ok | {:error, atom}

end
