defmodule Studio.Painting.Storage do
  @moduledoc """
  Studio.Painting.Storage defines the contract to store paintings
  """
  alias Studio.Painting

  @doc """
  Starts storage
  """
  @callback start_link() :: Supervisor.on_start()

  @doc """
  Finds a return a painting by name.
  """
  @callback find(name :: String.t) :: {:ok, Painting.t} | :error

  @doc """
  Check if a painting with a given name exists.
  """
  @callback exists?(name :: String.t) :: boolean

  @doc """
  Save a painting in the storage. If a painting with the same name exists, it will update it.
  """
  @callback save(Painting.t) :: :ok | {:error, atom}
end
