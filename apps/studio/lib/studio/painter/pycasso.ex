defmodule Studio.Painter.Pycasso do
  @moduledoc """
  Real implementation of a port that comunicates with pycasso to use with Studio.Painter
  """

  alias Painting.Settings

  def start(%Painting{} = painting) do
    executable = System.get_env("PYCASSO_PATH") || Application.get_env(:studio, :pycasso_path)

    Port.open({:spawn, "#{executable} #{args(painting)}"}, [:binary, {:packet, 4}, :nouse_stdio, :exit_status])
  end

  defp args(%Painting{} = painting) do
    required_args =
      [painting.content, painting.style, output_path(painting)]
      |> Enum.map(&inspect/1)

    (required_args ++ settings_args(painting.settings))
    |> Enum.join(" ")
  end

  defp output_path(painting) do
    Application.app_dir(:studio, "priv") <> "/paintings/" <> painting.name
  end

  defp settings_args(%Settings{} = settings) do
    [
      "-r port",
      "--initial_type #{settings.initial_type}",
      "--output_width #{settings.output_width}",
      "--iterations #{settings.iterations}",
      "--content_weight #{settings.content_weight}",
      "--style_weight #{settings.style_weight}",
      "--variation_weight #{settings.variation_weight}"
    ]
  end

end
