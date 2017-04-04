defmodule Studio.Painter.Pycasso do
  alias Studio.Painting
  alias Studio.Painting.Settings

  def start(%Painting{} = painting) do
    executable = Application.get_env(:studio, :pycasso_path)
    IO.inspect "#{executable} #{args(painting)}"
    Port.open({:spawn, "#{executable} #{args(painting)}"}, [:binary, {:packet, 4}, :nouse_stdio, :exit_status])
  end

  def args(%Painting{} = painting) do
    ([painting.content, painting.style, output_path()] ++ settings_args(painting.settings))
    |> Enum.join(" ")
  end

  def output_path() do
    Application.app_dir(:studio, "priv") <> "/output"
  end

  def settings_args(%Settings{output_width: output_width}) do
    ["-r port", "--output_width #{output_width}"]
  end

end
