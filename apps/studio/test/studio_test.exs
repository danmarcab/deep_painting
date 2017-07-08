defmodule StudioTest do
  use ExUnit.Case

  doctest Studio

  setup do
    :ok = Studio.clear_storage()
  end
end
