defmodule ChoicestWeb.CollectionControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Core
  alias Choicest.Core.Collection

  @create_attrs %{"description" => "some description", "name" => "some name", "voting_active" => true, "password" => "hunter2"}
  @update_attrs %{"description" => "some updated description", "name" => "some updated name", "voting_active" => false}
  @invalid_attrs %{"description" => nil, "name" => nil, "voting_active" => nil, "slug" => nil}
  @too_long_name_attrs %{"description" => "some description", "name" => "some way too long name that is over the character limit", "voting_active" => true}

  @another_collection_attrs %{"description" => "some description", "name" => "some other name", "voting_active" => true, "password" => "hunter2"}

  def fixture(:collection) do
    {:ok, collection} = Core.create_collection(@create_attrs)
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
    test "lists all collections", %{conn: conn} do
      conn = get conn, "/api/collections"
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create collection" do
    test "renders collection when data is valid", %{conn: conn} do
      conn = post conn, "/api/collections", collection: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, "/api/collections/#{id}"
      assert %{
        "id" => _id,
        "slug" => slug,
        "description" => description,
        "name" => name,
        "voting_active" => voting_active} = json_response(conn, 200)["data"]

      assert description == @create_attrs["description"]
      assert name == @create_attrs["name"]
      assert slug == "some-name"
      assert voting_active == @create_attrs["voting_active"]
      assert String.length(slug) > 0
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, "/api/collections", collection: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns validation error when name is too long", %{conn: conn} do
      conn = post conn, "/api/collections", collection: @too_long_name_attrs
      assert %{"name" => _name} = json_response(conn, 422)["errors"]
    end
  end

  describe "update collection" do
    setup [:create_collection]

    test "renders collection when data is valid", %{conn: conn, collection: %Collection{id: id} = collection, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> put("/api/collections/#{collection.id}", collection: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, "/api/collections/#{collection.id}"
      assert %{
        "id" => _id,
        "description" => description,
        "name" => name,
        "voting_active" => voting_active,
        "slug" => slug} = json_response(conn, 200)["data"]

      assert description == @update_attrs["description"]
      assert name == @update_attrs["name"]
      assert voting_active == @update_attrs["voting_active"]
      assert slug == "some-updated-name"
    end

    test "renders errors when data is invalid", %{conn: conn, collection: %Collection{id: id}, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> put("/api/collections/#{id}", collection: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 403 with missing authorization headers", %{conn: conn, collection: collection} do
      conn = put conn, "/api/collections/#{collection.id}", collection: @update_attrs

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with invalid authorization headers", %{conn: conn, collection: collection} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer token")
        |> put("/api/collections/#{collection.id}", collection: @update_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with authorization headers to wrong collection", %{conn: conn, jwt: jwt} do
      another = fixture(:another_collection)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> put("/api/collections/#{another.id}", collection: @update_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "delete collection" do
    setup [:create_collection]

    test "deletes chosen collection", %{conn: conn, collection: %Collection{id: id}, jwt: jwt} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> delete("/api/collections/#{id}")

      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, "/api/collections/#{id}"
      end
    end

    test "returns 403 with missing authorization headers", %{conn: conn, collection: %Collection{id: id}} do
      conn = delete conn, "/api/collections/#{id}"

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with invalid authorization headers", %{conn: conn, collection: %Collection{id: id}} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer token")
        |> delete("/api/collections/#{id}")

      assert json_response(conn, 403)["errors"] != %{}
    end

    test "returns 403 with authorization headers to wrong collection", %{conn: conn, jwt: jwt} do
      another = fixture(:another_collection)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> delete("/api/collections/#{another.id}")

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "get collection by slug" do
    setup [:create_collection]

    test "finds existing collection by slug", %{conn: conn, collection: %Collection{slug: slug}} do
      conn = get conn, "/api/collections/by_slug/#{slug}"
      assert json_response(conn, 200)["data"] != %{}
    end

    test "returns 404 when collection doesn't exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, "/api/collections/by_slug/non-existing-slug"
      end
    end
  end

  describe "get collection by id" do
    setup [:create_collection]

    test "finds existing collection by id", %{conn: conn, collection: %Collection{id: id}} do
      conn = get conn, "/api/collections/#{id}"
      assert json_response(conn, 200)["data"] != %{}
    end

    test "returns 404 when collection doesn't exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, "/api/collections/999999999"
      end
    end
  end

  defp create_collection(_) do
    collection = fixture(:collection)

    %{"jwt" => jwt} = authenticate(collection.id, @create_attrs["password"])
    {:ok, collection: collection, jwt: jwt}
  end

  defp authenticate(id, password) do
    conn = Phoenix.ConnTest.build_conn()
    conn = post conn, "/api/login", session: %{id: id, password: password}
    json_response(conn, 200)
  end

end
