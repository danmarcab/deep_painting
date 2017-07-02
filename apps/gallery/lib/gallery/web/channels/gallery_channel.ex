defmodule Gallery.Web.GalleryChannel do
  use Phoenix.Channel

  alias Gallery.Painting

  def join("gallery", _message, socket) do
    {:ok, Gallery.all_paintings() , socket}
  end

end
