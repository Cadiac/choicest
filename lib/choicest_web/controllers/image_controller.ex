defmodule ChoicestWeb.ImageController do
  use ChoicestWeb, :controller

  alias Choicest.Core
  alias Choicest.Core.Image

  action_fallback ChoicestWeb.FallbackController

  defp ensure_collection_permissions(conn, collection_id) do
    resource = Guardian.Plug.current_resource(conn)

    if Integer.to_string(resource.id) == collection_id do
      {:ok, collection_id}
    else
      {:error, "Collection id doesn't match token"}
    end
  end

  def index(conn, %{"collection_id" => collection_id}) do
    images = Core.list_images(collection_id)
    render(conn, "index.json", images: images)
  end

  def show(conn, %{"collection_id" => collection_id, "id" => id}) do
    image = Core.get_image!(collection_id, id)
    render(conn, "show.json", image: image)
  end

  def create(conn, %{"collection_id" => collection_id, "image" => image_params}) do
    case ensure_collection_permissions(conn, collection_id) do
      {:ok, _} ->
        with {:ok, %Image{} = image} <- Core.create_image(collection_id, image_params),
             {:ok, url} <- Core.create_presigned_url(collection_id, image.filename)
        do
          conn
          |> put_status(:created)
          |> put_resp_header("location", "/api/collections/${collection_id}/images/#{image.id}")
          |> render("upload.json", %{image: image, url: url})
        end
      {:error, reason} ->
        conn
        |> put_status(403)
        |> json(%{ error: reason })
    end
  end

  def update(conn, %{"collection_id" => collection_id, "id" => id, "image" => image_params}) do
    case ensure_collection_permissions(conn, collection_id) do
      {:ok, _} ->
        image = Core.get_image!(collection_id, id)

        with {:ok, %Image{} = image} <- Core.update_image(image, image_params) do
          render(conn, "show.json", image: image)
        end
      {:error, reason} ->
        conn
        |> put_status(403)
        |> json(%{ error: reason })
    end
  end

  def delete(conn, %{"collection_id" => collection_id, "id" => id}) do
    case ensure_collection_permissions(conn, collection_id) do
      {:ok, _} ->
        image = Core.get_image!(collection_id, id)
        with {:ok, %Image{}} <- Core.delete_image(image) do
          send_resp(conn, :no_content, "")
        end
      {:error, reason} ->
        conn
        |> put_status(403)
        |> json(%{ error: reason })
    end
  end
end
