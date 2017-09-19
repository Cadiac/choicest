defmodule ChoicestWeb.ImageControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Core
  alias Choicest.Model.Image

  @image_create_attrs %{description: "some description", original_filename: "some original_filename", content_type: "image/jpeg", file_size: 42, uploaded_by: "uploaded_by"}
  @image_update_attrs %{description: "some updated description"}
  @image_invalid_attrs %{description: nil, original_filename: nil, content_type: nil, file_size: nil, uploaded_by: nil}

  @collection_create_attrs %{"description" => "some description", "name" => "some name", "voting_active" => true, "password" => "hunter2"}
  @another_collection_attrs %{"description" => "some description", "name" => "some other name", "voting_active" => true, "password" => "hunter2"}

  def fixture(:image, collection_id) do
    {:ok, image} = Core.create_image(collection_id, @image_create_attrs)
    image
  end

  def fixture(:collection) do
    {:ok, collection} = Core.create_collection(@collection_create_attrs)
    collection
  end

  def fixture(:another_collection) do
    {:ok, collection} = Core.create_collection(@another_collection_attrs)
    collection
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_collection]

    test "lists all images", %{conn: conn, collection: collection} do
      conn = get conn, "/api/collections/#{collection.id}/images"
      assert json_response(conn, 200) == []
    end
  end

  describe "create image" do
    setup [:create_collection]

    test "creates image when data is valid", %{conn: conn, collection: collection, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> post("/api/collections/#{collection.id}/images", image: @image_create_attrs)

      assert %{"id" => id} = json_response(conn, 201)

      conn = get conn, "/api/collections/#{collection.id}/images/#{id}"
      assert %{
        "id" => _id,
        "description" => _description,
        "filename" => filename,
        "original_filename" => _original_filename,
        "url" => url,
        "content_type" => _content_type,
        "file_size" => _file_size,
        "uploaded_by" => _uploaded_by} = json_response(conn, 200)

      region = System.get_env("AWS_REGION")
      bucket = System.get_env("AWS_S3_COLLECTION_BUCKET")

      assert "https://s3-#{region}.amazonaws.com/#{bucket}/#{collection.id}/#{filename}" == url
    end

    test "returns errors when data is invalid", %{conn: conn, collection: collection, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> post("/api/collections/#{collection.id}/images", image: @image_invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 403 with missing authorization headers", %{conn: conn, collection: collection} do
      conn = post conn, "/api/collections/#{collection.id}/images", image: @image_create_attrs

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with invalid authorization headers", %{conn: conn, collection: collection} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer token")
        |> post("/api/collections/#{collection.id}/images", image: @image_create_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with authorization headers to wrong collection", %{conn: conn, jwt: jwt} do
      another = fixture(:another_collection)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> post("/api/collections/#{another.id}/images", image: @image_create_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "update image" do
    setup [:create_image]

    test "updates image when data is valid", %{conn: conn, image: %Image{id: id} = image, collection: collection, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> put("/api/collections/#{collection.id}/images/#{image.id}", image: @image_update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get conn, "/api/collections/#{collection.id}/images/#{image.id}"
      assert %{"description" => description} = json_response(conn, 200)
      assert description == @image_update_attrs.description
    end

    test "returns errors when data is invalid", %{conn: conn, image: image, collection: collection, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> put("/api/collections/#{collection.id}/images/#{image.id}", image: @image_invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 403 with missing authorization headers", %{conn: conn, image: image, collection: collection} do
      conn = put conn, "/api/collections/#{collection.id}/images/#{image.id}", image: @image_update_attrs

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with invalid authorization headers", %{conn: conn, image: image, collection: collection} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer token")
        |> put("/api/collections/#{collection.id}/images/#{image.id}", image: @image_update_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with authorization headers to wrong collection", %{conn: conn, image: image, jwt: jwt} do
      another = fixture(:another_collection)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> put("/api/collections/#{another.id}/images/#{image.id}", image: @image_update_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "delete image" do
    setup [:create_image]

    test "deletes chosen image", %{conn: conn, image: image, collection: collection, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> delete("/api/collections/#{collection.id}/images/#{image.id}")

      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, "/api/collections/#{collection.id}/images/#{image.id}"
      end
    end

    test "returns 403 with missing authorization headers", %{conn: conn, image: image, collection: collection} do
      conn = delete conn, "/api/collections/#{collection.id}/images/#{image.id}"

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with invalid authorization headers", %{conn: conn, image: image, collection: collection} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer token")
        |> delete("/api/collections/#{collection.id}/images/#{image.id}")

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with authorization headers to wrong collection", %{conn: conn, image: image, jwt: jwt} do
      another = fixture(:another_collection)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> delete("/api/collections/#{another.id}/images/#{image.id}")

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  defp create_collection(_) do
    collection = fixture(:collection)

    %{"jwt" => jwt} = authenticate(collection.id, @collection_create_attrs["password"])
    {:ok, collection: collection, jwt: jwt}
  end

  defp create_image(_) do
    collection = fixture(:collection)
    image = fixture(:image, collection.id)
    %{"jwt" => jwt} = authenticate(collection.id, @collection_create_attrs["password"])

    {:ok, image: image, collection: collection, jwt: jwt}
  end

  defp authenticate(id, password) do
    conn = Phoenix.ConnTest.build_conn()
    conn = post conn, "/api/login", session: %{id: id, password: password}
    json_response(conn, 200)
  end

end
