defmodule ChoicestWeb.ImageView do
  use ChoicestWeb, :view
  alias ChoicestWeb.ImageView

  def render("index.json", %{images: images}) do
    %{data: render_many(images, ImageView, "image.json")}
  end

  def render("show.json", %{image: image}) do
    %{data: render_one(image, ImageView, "image.json")}
  end

  def render("image.json", %{image: image}) do
    %{id: image.id,
      url: image.url,
      filename: image.filename,
      description: image.description,
      content_type: image.content_type,
      file_size: image.file_size}
  end
end
