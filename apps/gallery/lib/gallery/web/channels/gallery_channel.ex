defmodule Gallery.Web.GalleryChannel do
  @moduledoc """
  Channel that manages data for all paintings
  """
  use Phoenix.Channel

  def join("gallery", _message, socket) do
    paintings =
      Gallery.all_paintings()
      |> Enum.map(fn {name, painting} ->
        {name, Gallery.prepare_painting_for_ui(painting)}
      end)
      |> Enum.into(%{})

    {:ok, paintings, socket}
  end

end
