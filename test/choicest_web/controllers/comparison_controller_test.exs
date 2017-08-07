defmodule ChoicestWeb.ComparisonControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Contestants
  alias Choicest.Contestants.Image

  @create_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
  @missing_image 99999999

  def fixture(:image) do
    {:ok, image} = Contestants.create_image(@create_attrs)
    image
  end

  def fixture(:comparison) do
    %Image{id: winner_id} = fixture(:image)
    %Image{id: loser_id} = fixture(:image)

    {:ok, comparison} = Contestants.create_comparison(winner_id, loser_id)

    comparison
  end

  defp create_image(_) do
    image = fixture(:image)
    {:ok, image: image}
  end

  defp create_winner_loser(_) do
    %Image{id: winner_id} = fixture(:image)
    %Image{id: loser_id} = fixture(:image)

    {:ok, winner_id: winner_id, loser_id: loser_id}
  end

  defp create_comparison(_) do
    comparison = fixture(:comparison)
    {:ok, comparison: comparison}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create comparison" do
    setup [:create_winner_loser]

    test "creates comparison between images", %{conn: conn, winner_id: winner_id, loser_id: loser_id} do
      conn = post conn, "/api/comparisons/", %{winner_id: winner_id, loser_id: loser_id}

      assert %{"winner" => winner} = json_response(conn, 201)["data"]
      assert %{"loser" => loser} = json_response(conn, 201)["data"]

      assert winner["id"] == winner_id
      assert loser["id"] == loser_id
    end

    test "returns error if one or both of the images are missing", %{conn: conn, winner_id: winner_id, loser_id: loser_id} do
      assert_error_sent 404, fn ->
        post conn, "/api/comparisons/", %{winner_id: winner_id, loser_id: @missing_image}
      end

      assert_error_sent 404, fn ->
        post conn, "/api/comparisons/", %{winner_id: @missing_image, loser_id: loser_id}
      end

      assert_error_sent 404, fn ->
        post conn, "/api/comparisons/", %{winner_id: @missing_image, loser_id: @missing_image}
      end
    end
  end

  describe "get comparison by id" do
    setup [:create_comparison]

    test "gets existing comparison by id", %{conn: conn, comparison: comparison} do
      conn = get conn, "/api/comparisons/#{comparison.id}"

      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert %{"winner" => winner} = json_response(conn, 200)["data"]
      assert %{"loser" => loser} = json_response(conn, 200)["data"]

      assert winner["id"] == comparison.winner_id
      assert loser["id"] == comparison.loser_id

      assert id == comparison.id
    end

    test "returns error for missing image", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, "/api/comparisons/99999999"
      end
    end
  end

  describe "comparison results" do
    setup [:create_image]

    test "lists empty comparisons correctly", %{conn: conn, image: image} do
      conn = get conn, "/api/comparisons/results/#{image.id}"
      assert json_response(conn, 200)["won_against"] == []
      assert json_response(conn, 200)["lost_against"] == []
    end
  end
end
