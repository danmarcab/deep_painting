defmodule StudioTest do
  use ExUnit.Case
  doctest Studio

  setup do
    :ok = Studio.Painting.Storage.Memory.clear()
  end
end
