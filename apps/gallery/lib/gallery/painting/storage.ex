defmodule Gallery.Painting.Storage do
  @moduledoc """
  Gallery.Painting.Storage defines the contract to store paintings
  """
  alias Gallery.Painting

  @doc """
  Returns if need to be supervised (process) or not (ets, dets...)
  """
  @callback supervise?() :: boolean

  @doc """
  Starts storage and link
  """
  @callback start_link() :: Supervisor.on_start()

  @doc """
  Starts storage
  """
  @callback start() :: :ok | :error

  @doc """
  Finds a return a painting by name.
  """
  @callback find(name :: String.t) :: {:ok, Painting.t} | :error

  @doc """
  Return a map with all paintings on the storage.
  """
  @callback all() :: {:ok, %{optional(String.t) => Painting.t}} | :error


  @doc """
  Check if a painting with a given name exists.
  """
  @callback exists?(name :: String.t) :: boolean

  @doc """
  Save a painting in the storage. If a painting with the same name exists, it will update it.
  """
  @callback save(Painting.t) :: :ok | {:error, atom}

  @optional_callbacks start_link: 0, start: 0
end
