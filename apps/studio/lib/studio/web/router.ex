defmodule Studio.Web.Router do
  use Plug.Router

  alias Painting.Settings

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :match
  plug :dispatch

  post "/paint" do
    case process_params(conn.params) do
      %{name: name,
        content_path: content_path,
        style_path: style_path,
        settings: settings,
        callback_url: callback_url} ->

        Studio.create_painting(name)
        Studio.add_painting_content(name, content_path)
        Studio.add_painting_style(name, style_path)
        Studio.add_painting_settings(name, settings)
        Studio.start_painting(name, callback_url)

        send_resp(conn, 200, "Painting started")
      :error ->
        send_resp(conn, 500, "Internal Error")
    end
  end

  def process_params(%{"name" => name,
                       "content" => content_img,
                       "style" => style_img,
                       "settings" => encoded_settings,
                       "callback_url" => callback_url}) do

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
      settings: Poison.decode!(encoded_settings, as: %Settings{}),
      callback_url: callback_url
    }
  end
  def process_params(_),  do: :error

end
