defmodule StudioTest do
  use ExUnit.Case
  doctest Studio

  setup do
    :ok = Studio.Painting.Storage.Memory.clear()
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
