defmodule Studio.PaintingTest do
  use ExUnit.Case

  alias Studio.Painting
  alias Studio.Painting.Settings

  doctest Painting

  def ready_painting do
    %Painting{status: :ready}
  end

  def in_progress_painting do
    %Painting{status: :in_progress}
  end
end
