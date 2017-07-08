defmodule Studio.PainterTest do
  use ExUnit.Case

  setup do
    :ok = Studio.clear_storage()

    Studio.create_painting("my_painting")
    Studio.add_painting_content("my_painting", "content.png")
    Studio.add_painting_style("my_painting", "style.png")
    Studio.add_painting_settings("my_painting", %{Painting.Settings.new| iterations: 10})
  end

  test "watcher is notified on every iteration until it completes the painting" do
    Studio.Painter.start_link("my_painting", watcher: self())

    for _ <- 0..10 do
      assert_receive({:painter, "my_painting", %Painting.Iteration{}})
    end
    refute_receive({:painter, "my_painting", %Painting.Iteration{}})
    assert {:ok, %{status: :complete}} = Studio.find_painting("my_painting")
  end

  test "can stop the painter, and completes painting" do
    {:ok, painter} = Studio.Painter.start_link("my_painting", watcher: self())

    for _ <- 0..5 do
      assert_receive({:painter, "my_painting", %Painting.Iteration{}})
    end
    Studio.Painter.stop(painter)
    refute_receive({:painter, "my_painting", %Painting.Iteration{}})
    assert {:ok, %{status: :complete}} = Studio.find_painting("my_painting")
  end


end
