defmodule ChoicestWeb.CollectionController do
  use ChoicestWeb, :controller

  alias Choicest.Core
  alias Choicest.Core.Collection

  require Logger

  action_fallback ChoicestWeb.FallbackController

  defp ensure_collection_permissions(conn, collection_id) do
    resource = Guardian.Plug.current_resource(conn)

    if Integer.to_string(resource.id) == collection_id do
      {:ok, collection_id}
    else
      {:error, "Collection id doesn't match token"}
    end
  end

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
    case ensure_collection_permissions(conn, id) do
      {:ok, _} ->
        collection = Core.get_collection!(id)

        with {:ok, %Collection{} = collection} <- Core.update_collection(collection, collection_params) do
          render(conn, "show.json", collection: collection)
        end
      {:error, reason} ->
        conn
        |> put_status(403)
        |> json(%{ error: reason })
    end
  end

  def delete(conn, %{"id" => id}) do
    case ensure_collection_permissions(conn, id) do
      {:ok, _} ->
        collection = Core.get_collection!(id)
        with {:ok, %Collection{}} <- Core.delete_collection(collection) do
          send_resp(conn, :no_content, "")
        end
      {:error, reason} ->
        conn
        |> put_status(403)
        |> json(%{ error: reason })
    end
  end
end
