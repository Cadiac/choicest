defmodule ChoicestWeb.ComparisonControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Collections
  alias Choicest.Collections.Image

  @create_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
  @missing_image 99999999

  def fixture(:collection) do
    {:ok, collection} = Collections.create_collection(@collection_create_attrs)
    collection
  end

  def fixture(:image, collection_id) do
    {:ok, image} = Collections.create_image(collection_id, @image_create_attrs)
    image
  end

  def fixture(:comparison, collection_id) do
    %Image{id: winner_id} = fixture(:image)
    %Image{id: loser_id} = fixture(:image)

    {:ok, comparison} = Collections.create_comparison(collection_id, winner_id, loser_id)

    comparison
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create comparison" do
    setup [:create_winner_loser]

    test "creates comparison between images", %{conn: conn, winner_id: winner_id, loser_id: loser_id, collection: collection} do
      conn = post conn, "/api/collections/#{collection.id}/comparisons", %{winner_id: winner_id, loser_id: loser_id}

      assert %{"winner" => winner} = json_response(conn, 201)["data"]
      assert %{"loser" => loser} = json_response(conn, 201)["data"]

      assert winner["id"] == winner_id
      assert loser["id"] == loser_id
    end

    test "returns error if one or both of the images are missing", %{conn: conn, winner_id: winner_id, loser_id: loser_id, collection: collection} do
      assert_error_sent 404, fn ->
        post conn, "/api/collections/#{collection.id}/comparisons", %{winner_id: winner_id, loser_id: @missing_image}
      end

      assert_error_sent 404, fn ->
        post conn, "/api/collections/#{collection.id}/comparisons", %{winner_id: @missing_image, loser_id: loser_id}
      end

      assert_error_sent 404, fn ->
        post conn, "/api/collections/#{collection.id}/comparisons", %{winner_id: @missing_image, loser_id: @missing_image}
      end
    end
  end

  describe "get comparison by id" do
    setup [:create_comparison]

    test "gets existing comparison by id", %{conn: conn, comparison: comparison, collection: collection} do
      conn = get conn, "/api/collections/#{collection.id}/comparisons/#{comparison.id}"

      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert %{"winner" => winner} = json_response(conn, 200)["data"]
      assert %{"loser" => loser} = json_response(conn, 200)["data"]

      assert winner["id"] == comparison.winner_id
      assert loser["id"] == comparison.loser_id

      assert id == comparison.id
    end

    test "returns error for missing image", %{conn: conn, collection: collection} do
      assert_error_sent 404, fn ->
        get conn, "/api/collections/#{collection.id}/comparisons/99999999"
      end
    end
  end

  describe "comparison results" do
    setup [:create_image]

    test "lists empty comparisons correctly", %{conn: conn, image: image, collection: collection} do
      conn = get conn, "/api/collections/#{collection.id}/comparisons/results/#{image.id}"
      assert json_response(conn, 200)["won_against"] == []
      assert json_response(conn, 200)["lost_against"] == []
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

  defp create_winner_loser(_) do
    collection = fixture(:collection)

    %Image{id: winner_id} = fixture(:image, collection.id)
    %Image{id: loser_id} = fixture(:image, collection.id)

    {:ok, winner_id: winner_id, loser_id: loser_id, collection: collection}
  end

  defp create_comparison(_) do
    collection = fixture(:collection)
    comparison = fixture(:comparison, collection.id)

    {:ok, comparison: comparison, collection: collection}
  end
end
