defmodule ChoicestWeb.SessionControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Core
  alias Choicest.Core.Collection

  @collection_create_attrs %{"description" => "some description", "name" => "some name", "voting_active" => true, "password" => "hunter2"}

  def fixture(:collection) do
    {:ok, collection} = Core.create_collection(@collection_create_attrs)
    collection
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "authorization" do
    setup [:create_collection]

    test "creates jwt token when password and collection id match", %{conn: conn, collection: %Collection{id: id} = _} do
      conn = post conn, "/api/login", session: %{id: id, password: @collection_create_attrs["password"]}
      assert %{"jwt" => jwt} = json_response(conn, 200)
      assert String.length(jwt) > 0
    end

    test "returns 401 with errors when password is wrong", %{conn: conn, collection: %Collection{id: id} = _} do
      conn = post conn, "/api/login", session: %{id: id, password: "foobar"}
      assert %{"error" => error} = json_response(conn, 401)
      assert error == "Invalid collection id or password"
    end

    test "returns 401 when colletion doesn't exist", %{conn: conn} do
      conn = post conn, "/api/login", session: %{id: 999999999, password: "hunter2"}
      assert %{"error" => error} = json_response(conn, 401)
      assert error == "Invalid collection id or password"
    end
  end

  defp create_collection(_) do
    collection = fixture(:collection)
    {:ok, collection: collection}
  end
end
