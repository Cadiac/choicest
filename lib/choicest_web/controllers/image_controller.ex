defmodule ChoicestWeb.ImageController do
  use ChoicestWeb, :controller

  alias Choicest.Core
  alias Choicest.Core.Image

  action_fallback ChoicestWeb.FallbackController

  def index(conn, %{"collection_id" => collection_id}) do
    images = Core.list_images(collection_id)
    render(conn, "index.json", images: images)
  end

  def show(conn, %{"collection_id" => collection_id, "id" => id}) do
    image = Core.get_image!(collection_id, id)
    render(conn, "show.json", image: image)
  end

  def create(conn, %{"collection_id" => collection_id, "image" => image_params}) do
    with {:ok, %Image{} = image} <- Core.create_image(collection_id, image_params),
         {:ok, url} <- Core.create_presigned_url(collection_id, image.filename)
    do
      conn
      |> put_status(:created)
      |> put_resp_header("location", "/api/collections/${collection_id}/images/#{image.id}")
      |> render("upload.json", %{image: image, url: url})
    end
  end

  def update(conn, %{"collection_id" => collection_id, "id" => id, "image" => image_params}) do
    image = Core.get_image!(collection_id, id)

    with {:ok, %Image{} = image} <- Core.update_image(image, image_params) do
      render(conn, "show.json", image: image)
    end
  end

  def delete(conn, %{"collection_id" => collection_id, "id" => id}) do
    image = Core.get_image!(collection_id, id)
    with {:ok, %Image{}} <- Core.delete_image(image) do
      send_resp(conn, :no_content, "")
    end
  end
end
