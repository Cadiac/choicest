defmodule ChoicestWeb.ImageControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Core
  alias Choicest.Core.Image

  @image_create_attrs %{description: "some description", original_filename: "some original_filename", content_type: "image/jpeg", file_size: 42, uploaded_by: "uploaded_by"}
  @image_update_attrs %{description: "some updated description"}
  @image_invalid_attrs %{description: nil, original_filename: nil, content_type: nil, file_size: nil, uploaded_by: nil}

  @collection_create_attrs %{"description" => "some description", "name" => "some name", "voting_active" => true}

  def fixture(:image, collection_id) do
    {:ok, image} = Core.create_image(collection_id, @image_create_attrs)
    image
  end

  def fixture(:collection) do
    {:ok, collection} = Core.create_collection(@collection_create_attrs)
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

    test "creates image when data is valid", %{conn: conn, collection: collection} do
      conn = post conn, "/api/collections/#{collection.id}/images", image: @image_create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, "/api/collections/#{collection.id}/images/#{id}"

      assert %{
        "id" => _id,
        "description" => _description,
        "filename" => filename,
        "original_filename" => _original_filename,
        "url" => url,
        "content_type" => _content_type,
        "file_size" => _file_size,
        "uploaded_by" => _uploaded_by} = json_response(conn, 200)["data"]

      region = System.get_env("AWS_REGION")
      bucket = System.get_env("AWS_S3_COLLECTION_BUCKET")

      assert "https://s3-#{region}.amazonaws.com/#{bucket}/#{collection.id}/#{filename}" == url
    end

    test "returns errors when data is invalid", %{conn: conn, collection: collection} do
      conn = post conn, "/api/collections/#{collection.id}/images", image: @image_invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update image" do
    setup [:create_image]

    test "updates image when data is valid", %{conn: conn, image: %Image{id: id} = image, collection: collection} do
      conn = put conn, "/api/collections/#{collection.id}/images/#{image.id}", image: @image_update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, "/api/collections/#{collection.id}/images/#{image.id}"
      assert %{"description" => description} = json_response(conn, 200)["data"]
      assert description == @image_update_attrs.description
    end

    test "returns errors when data is invalid", %{conn: conn, image: image, collection: collection} do
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
