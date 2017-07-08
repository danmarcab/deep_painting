defmodule Gallery.Web.PaintingController do
  use Gallery.Web, :controller

  alias Painting.Iteration

  def add_iteration(conn, %{"name" => painting_name, "loss" => loss, "file" => file}) do
    IO.inspect "*************"
    IO.inspect painting_name
    IO.inspect loss
    IO.inspect file
    IO.inspect "*************"

    base_path = painting_path(painting_name)
    :ok = File.mkdir_p(base_path)
    file_path = base_path <> file.filename

    IO.inspect "*************"
    IO.inspect file_path
    IO.inspect base_path
    IO.inspect "*************"

    :ok = File.cp(file.path, file_path)

    {:ok, painting} = Gallery.find_painting(painting_name)
    painting = Painting.add_iteration(painting, %Iteration{loss: elem(Float.parse(loss), 0), file_name: file.filename})
    Gallery.save_painting(painting)

    text conn, "Ok"
  end

  defp painting_path(name) do
    Application.app_dir(:gallery, "priv") <> "/static/paintings/" <> name <> "/"
  end
end
