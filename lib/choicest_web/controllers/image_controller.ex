defmodule ChoicestWeb.ImageController do
  use ChoicestWeb, :controller

  alias Choicest.Collections
  alias Choicest.Collections.Image

  action_fallback ChoicestWeb.FallbackController

  def index(conn, _params) do
    images = Collections.list_images()
    render(conn, "index.json", images: images)
  end

  def create(conn, %{"image" => image_params}) do
    with {:ok, %Image{} = image} <- Collections.create_image(image_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", image_path(conn, :show, image))
      |> render("show.json", image: image)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Collections.get_image!(id)
    render(conn, "show.json", image: image)
  end

  def update(conn, %{"id" => id, "image" => image_params}) do
    image = Collections.get_image!(id)

    with {:ok, %Image{} = image} <- Collections.update_image(image, image_params) do
      render(conn, "show.json", image: image)
    end
  end

  def delete(conn, %{"id" => id}) do
    image = Collections.get_image!(id)
    with {:ok, %Image{}} <- Collections.delete_image(image) do
      send_resp(conn, :no_content, "")
    end
  end
end
