defmodule ChoicestWeb.ImageController do
  use ChoicestWeb, :controller

  alias Choicest.Collections
  alias Choicest.Collections.Image

  action_fallback ChoicestWeb.FallbackController

  def index(conn, %{"collection_id" => collection_id}) do
    images = Collections.list_images(collection_id)
    render(conn, "index.json", images: images)
  end

  def show(conn, %{"collection_id" => collection_id, "id" => id}) do
    image = Collections.get_image!(collection_id, id)
    render(conn, "show.json", image: image)
  end

  def create(conn, %{"collection_id" => collection_id, "image" => image_params}) do
    with {:ok, %Image{} = image} <- Collections.create_image(collection_id, image_params),
         {:ok, url} <- Collections.create_presigned_url(image.filename)
    do
      conn
      |> put_status(:created)
      |> put_resp_header("location", "/api/collections/${collection_id}/images/#{image.id}")
      |> render("upload.json", %{image: image, url: url})
    end
  end

  def update(conn, %{"collection_id" => collection_id, "id" => id, "image" => image_params}) do
    image = Collections.get_image!(collection_id, id)

    with {:ok, %Image{} = image} <- Collections.update_image(image, image_params) do
      render(conn, "show.json", image: image)
    end
  end

  def delete(conn, %{"collection_id" => collection_id, "id" => id}) do
    image = Collections.get_image!(collection_id, id)
    with {:ok, %Image{}} <- Collections.delete_image(image) do
      send_resp(conn, :no_content, "")
    end
  end
end
