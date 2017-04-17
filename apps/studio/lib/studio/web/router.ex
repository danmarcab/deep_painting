defmodule Studio.Web.Router do
  use Plug.Router

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :match
  plug :dispatch

  post "/paint" do
    IO.puts "Params"
    IO.puts(inspect conn.params)

    # check params and return errors
    %{
      name: name,
      content_path: content_path,
      style_path: style_path,
      settings: settings
    } = process_params(conn.params)

    # paint
    Studio.create_painting(name)
    Studio.add_painting_content(name, content_path)
    Studio.add_painting_style(name, style_path)
    Studio.add_painting_settings(name, settings)
    Studio.start_painting(name)

    send_resp(conn, 200, "Painting started")
  end
  
  def process_params(%{"name" => name, "content" => content_img, "style" => style_img}) do
    painting_path = Application.app_dir(:studio, "priv") <> "/paintings/" <> name <> "/"

    File.mkdir_p(painting_path)
    content_path = painting_path <> content_img.filename
    style_path = painting_path <> style_img.filename

    :ok = File.cp(content_img.path, content_path)
    :ok = File.cp(style_img.path, style_path)

    %{
      name: name,
      content_path: content_path,
      style_path: style_path,
      settings: Studio.Painting.Settings.new
    }
  end
end
