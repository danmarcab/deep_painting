defmodule StudioTest do
  use ExUnit.Case
  alias Studio.Painting

  doctest Studio

  setup do
    :ok = Studio.Painting.Storage.Memory.clear()
  end
end
