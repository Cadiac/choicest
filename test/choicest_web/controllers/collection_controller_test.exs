defmodule ChoicestWeb.CollectionControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Collections
  alias Choicest.Collections.Collection

  @create_attrs %{description: "some description", name: "some name", voting_active: true}
  @update_attrs %{description: "some updated description", name: "some updated name", voting_active: false}
  @invalid_attrs %{description: nil, name: nil, voting_active: nil}

  def fixture(:collection) do
    {:ok, collection} = Collections.create_collection(@create_attrs)
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
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some description",
        "name" => "some name",
        "voting_active" => true}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, "/api/collections", collection: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update collection" do
    setup [:create_collection]

    test "renders collection when data is valid", %{conn: conn, collection: %Collection{id: id} = collection} do
      conn = put conn, "/api/collections/#{id}", collection: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, "/api/collections/#{id}"
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some updated description",
        "name" => "some updated name",
        "voting_active" => false}
    end

    test "renders errors when data is invalid", %{conn: conn, collection: %Collection{id: id}} do
      conn = put conn, "/api/collections/#{id}", collection: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete collection" do
    setup [:create_collection]

    test "deletes chosen collection", %{conn: conn, collection: %Collection{id: id}} do
      conn = delete conn, "/api/collections/#{id}"
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, "/api/collections/#{id}"
      end
    end
  end

  defp create_collection(_) do
    collection = fixture(:collection)
    {:ok, collection: collection}
  end
end
