defmodule PaintingTest do
  use ExUnit.Case

  alias Painting.Settings

  doctest Painting

  def ready_painting do
    %Painting{status: :ready}
  end

  def in_progress_painting do
    %Painting{status: :in_progress}
  end
end
