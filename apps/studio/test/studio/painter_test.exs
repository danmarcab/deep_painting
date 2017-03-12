defmodule Studio.PainterTest do
  use ExUnit.Case

  test "watcher is notified on every iteration" do
    Studio.create_painting("my_painting")
    Studio.Painter.start_link("my_painting", iterations: 10, watcher: self())

    for _ <- 0..10 do
      assert_receive({:painter, "my_painting"})
    end
    refute_receive({:painter, "my_painting"})
  end

  test "can stop the painter" do
    Studio.create_painting("my_painting")
    {:ok, painter} = Studio.Painter.start_link("my_painting", iterations: 10, watcher: self())

    for _ <- 0..5 do
      assert_receive({:painter, "my_painting"})
    end
    Studio.Painter.stop(painter)
    refute_receive({:painter, "my_painting"})
  end


end
