defmodule ChoicestWeb.CollectionController do
  use ChoicestWeb, :controller

  alias Choicest.Core
  alias Choicest.Core.Collection

  action_fallback ChoicestWeb.FallbackController

  def index(conn, _params) do
    collections = Core.list_collections()
    render(conn, "index.json", collections: collections)
  end

  def show(conn, %{"id" => id}) do
    collection = Core.get_collection!(id)
    render(conn, "show.json", collection: collection)
  end

  def get_by_slug(conn, %{"slug" => slug}) do
    collection = Core.get_collection_by_slug!(slug)
    render(conn, "show.json", collection: collection)
  end

  def create(conn, %{"collection" => collection_params}) do
    with {:ok, %Collection{} = collection} <- Core.create_collection(collection_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", "/api/collections/#{collection.id}")
      |> render("show.json", collection: collection)
    end
  end

  def update(conn, %{"id" => id, "collection" => collection_params}) do
    collection = Core.get_collection!(id)

    with {:ok, %Collection{} = collection} <- Core.update_collection(collection, collection_params) do
      render(conn, "show.json", collection: collection)
    end
  end

  def delete(conn, %{"id" => id}) do
    collection = Core.get_collection!(id)
    with {:ok, %Collection{}} <- Core.delete_collection(collection) do
      send_resp(conn, :no_content, "")
    end
  end
end
