defmodule Gallery.Web.PaintingChannel do
  @moduledoc """
  Channel that manages data for one painting
  """
  use Phoenix.Channel

  require Logger
  alias Painting.Settings
  alias Gallery.Painting.Broker

  def join("painting:" <> painting_name, _message, socket) do
    resp = case Gallery.find_painting(painting_name) do
      {:ok, painting} -> Gallery.prepare_painting_for_ui(painting)
      :error -> %{error: :not_found}
    end

    {:ok, resp , socket}
  end

  def handle_in("start", payload, socket) do
    painting = payload_to_painting(payload)

    :ok = Gallery.save_painting(painting)

    Broker.start_painting(painting)

    {:noreply, socket}
  end

  defp payload_to_painting(%{"name" => name, "content" => content, "style" => style, "settings" => settings}) do
    base_path = painting_path(name)
    :ok = File.mkdir_p(base_path)

    content_name = "content" <> Path.extname(content)
    content_path = base_path <> content_name
    style_name = "style" <> Path.extname(style)
    style_path = base_path <> style_name

    {:ok, %HTTPoison.Response{body: content_data}} = HTTPoison.get(content)
    {:ok, %HTTPoison.Response{body: style_data}} = HTTPoison.get(style)

    File.open(content_path, [:write], fn(file) ->
      IO.binwrite(file, content_data)
    end)
    File.open(style_path, [:write], fn(file) ->
      IO.binwrite(file, style_data)
    end)

    name
    |> Painting.new
    |> Painting.add_content(content_name)
    |> Painting.add_style(style_name)
    |> Painting.add_settings(payload_to_settings(settings))
  end

  defp payload_to_settings(%{"content_weight" => co_w,
                             "style_weight" => st_w,
                             "variation_weight" => var_w,
                             "iterations" => iters,
                             "output_width" => out_w,
                             "initial_type" => initial_type}) do
    %Settings{iterations: iters,
              content_weight: co_w,
              style_weight: st_w,
              variation_weight: var_w,
              output_width: out_w,
              initial_type: initial_type}
  end

  defp painting_path(name) do
    Application.app_dir(:gallery, "priv") <> "/static/paintings/" <> name <> "/"
  end

end
