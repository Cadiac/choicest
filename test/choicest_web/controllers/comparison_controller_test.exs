defmodule ChoicestWeb.ComparisonControllerTest do
  use ChoicestWeb.ConnCase

  alias Choicest.Contestants
  alias Choicest.Contestants.Image
  alias Choicest.Contestants.Comparison

  @create_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
  @update_attrs %{content_type: "some updated content_type", description: "some updated description", file_size: 43, filename: "some updated filename", url: "some updated url"}
  @invalid_attrs %{content_type: nil, description: nil, file_size: nil, filename: nil, url: nil}

  def fixture(:image) do
    {:ok, image} = Contestants.create_image(@create_attrs)
    image
  end

  defp create_image(_) do
    image = fixture(:image)
    {:ok, image: image}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_image]

    test "lists empty comparisons correctly", %{conn: conn, image: image} do
      conn = get conn, "/api/comparisons/results/#{image.id}"
      assert json_response(conn, 200)["won_against"] == []
      assert json_response(conn, 200)["lost_against"] == []
    end
  end
end
