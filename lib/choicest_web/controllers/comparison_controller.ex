defmodule ChoicestWeb.ComparisonController do
  use ChoicestWeb, :controller

  alias Choicest.Contestants
  alias Choicest.Contestants.Comparison
  alias Choicest.Contestants.Image

  action_fallback ChoicestWeb.FallbackController

  def index(conn, _params) do
    images = Contestants.list_images()
    render(conn, "index.json", images: images)
  end

  def create(conn, %{"image" => image_params}) do
    with {:ok, %Image{} = image} <- Contestants.create_image(image_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", image_path(conn, :show, image))
      |> render("show.json", image: image)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Contestants.get_image!(id)
    render(conn, "show.json", image: image)
  end

  def update(conn, %{"id" => id, "image" => image_params}) do
    image = Contestants.get_image!(id)

    with {:ok, %Image{} = image} <- Contestants.update_image(image, image_params) do
      render(conn, "show.json", image: image)
    end
  end

  def delete(conn, %{"id" => id}) do
    image = Contestants.get_image!(id)
    with {:ok, %Image{}} <- Contestants.delete_image(image) do
      send_resp(conn, :no_content, "")
    end
  end
end
