defmodule Gallery.Web.PaintingChannel do
  use Phoenix.Channel

  alias Gallery.Painting
  alias Gallery.Painting.Settings

  def join("painting:" <> painting_name, _message, socket) do
    # should come from some registry or DB
#    painting = %{name: painting_name, status: :not_found}

    resp = case Gallery.find_painting(painting_name) do
      {:ok, painting} -> painting
      :error -> %{error: :not_found}
    end
#    painting =
#      %{
#        name: painting_name,
#        status: :new,
#        iterations: [],
#        content_path: "mmmm",
#        style_path: "sdsds",
#        settings: %{
#          iterations: 17,
#          content_weight: 10,
#          style_weight: 100,
#          variation_weight: 1,
#          output_width: 300
#        }
#      }

    {:ok, resp , socket}
  end

  def handle_in("start", payload, socket) do
#    update painting settings and start painting!
    painting = payloadToPainting(payload)
    IO.inspect painting

    :ok = Gallery.save_painting(painting)

    {:noreply, socket}
  end

  defp payloadToPainting(%{"name" => name, "content" => content, "style" => style, "settings" => settings}) do

    Painting.new(name)
    |> Painting.add_content(content)
    |> Painting.add_style(style)
    |> Painting.add_settings(payloadToSettings(settings))
  end

  defp payloadToSettings(%{"content_weight" => co_w, "style_weight" => st_w, "variation_weight" => var_w, "iterations" => iters, "output_width" => out_w}) do
    %Settings{iterations: iters, content_weight: co_w, style_weight: st_w, variation_weight: var_w, output_width: out_w}
  end
end
