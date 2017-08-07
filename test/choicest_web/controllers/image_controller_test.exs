defmodule ChoicestWeb.ImageControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Collections
  alias Choicest.Collections.Image

  @image_create_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
  @image_update_attrs %{content_type: "some updated content_type", description: "some updated description", file_size: 43, filename: "some updated filename", url: "some updated url"}
  @image_invalid_attrs %{content_type: nil, description: nil, file_size: nil, filename: nil, url: nil}

  @collection_create_attrs %{description: "some description", name: "some name", voting_active: true}

  def fixture(:image, collection_id) do
    {:ok, image} = Collections.create_image(@image_create_attrs)
    image
  end

  def fixture(:collection) do
    {:ok, collection} = Collections.create_collection(@collection_create_attrs)
    collection
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_collection]

    test "lists all images", %{conn: conn, collection: collection} do
      conn = get conn, "/api/collections/#{collection.id}/images"
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create image" do
    setup [:create_collection]

    test "renders image when data is valid", %{conn: conn, collection: collection} do
      conn = post conn, "/api/collections/#{collection.id}/images", image: @image_create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, "/api/collections/#{collection.id}/images"
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "content_type" => "some content_type",
        "description" => "some description",
        "file_size" => 42,
        "filename" => "some filename",
        "url" => "some url"}
    end

    test "renders errors when data is invalid", %{conn: conn, collection: collection} do
      conn = post conn, "/api/collections/#{collection.id}/images", image: @image_invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update image" do
    setup [:create_image]

    test "renders image when data is valid", %{conn: conn, image: %Image{id: id} = image, collection: collection} do
      conn = put conn, "/api/collections/#{collection.id}/images/#{id}", image: @image_update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, "/api/collections/#{collection.id}/images/#{id}"
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "content_type" => "some updated content_type",
        "description" => "some updated description",
        "file_size" => 43,
        "filename" => "some updated filename",
        "url" => "some updated url"}
    end

    test "renders errors when data is invalid", %{conn: conn, image: image, collection: collection} do
      conn = put conn, "/api/collections/#{collection.id}/images/#{image.id}", image: @image_invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete image" do
    setup [:create_image]

    test "deletes chosen image", %{conn: conn, image: image, collection: collection} do
      conn = delete conn, "/api/collections/#{collection.id}/images/#{image.id}"
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, "/api/collections/#{collection.id}/images/#{image.id}"
      end
    end
  end

  defp create_collection(_) do
    collection = fixture(:collection)
    {:ok, collection: collection}
  end

  defp create_image(_) do
    collection = fixture(:collection)
    image = fixture(:image, collection.id)

    {:ok, image: image, collection: collection}
  end
end
