defmodule Studio.Painting.Storage do
  @moduledoc """
  Studio.Painting.Storage defines the contract to store paintings
  """

  @doc """
  Starts storage
  """
  @callback start_link() :: Supervisor.on_start()

  @doc """
  Creates a painting with a given name
  """
  @callback create(name :: String.t) :: :ok | {:error, atom}

  @doc """
  Adds the content to the painting
  """
  @callback add_content(name :: String.t, content :: String.t) :: :ok | {:error, atom}

  @doc """
  Adds the style to the painting
  """
  @callback add_style(name :: String.t, style :: String.t) :: :ok | {:error, atom}

  @doc """
  Adds the settings to the painting
  """
  @callback add_settings(name :: String.t, style :: String.t) :: :ok | {:error, atom}

  @doc """
  Checks if a picture with a given name exists
  """
  @callback has_painting?(name :: String.t) :: boolean
end
