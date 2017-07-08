defmodule Studio.Painter.Pycasso do
  @moduledoc """
  Real implementation of a port that comunicates with pycasso to use with Studio.Painter
  """

  alias Painting.Settings

  defp start(%Painting{} = painting) do
    executable = Application.get_env(:studio, :pycasso_path)

    Port.open({:spawn, "#{executable} #{args(painting)}"}, [:binary, {:packet, 4}, :nouse_stdio, :exit_status])
  end

  defp args(%Painting{} = painting) do
    ([painting.content, painting.style, output_path(painting)] ++ settings_args(painting.settings))
    |> Enum.join(" ")
  end

  defp output_path(painting) do
    Application.app_dir(:studio, "priv") <> "/paintings/" <> painting.name
  end

  defp settings_args(%Settings{output_width: output_width}) do
    ["-r port", "--output_width #{output_width}"]
  end

end
