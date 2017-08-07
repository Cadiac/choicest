defmodule Choicest.ComparisonsTest do
  use Choicest.DataCase

  alias Choicest.Collections

  describe "comparisons" do
    alias Choicest.Collections.Image
    alias Choicest.Collections.Comparison

    @valid_image_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_image_attrs)
        |> Collections.create_image()

      image
    end

    def comparison_fixture() do
      %Image{id: winner_id} = image_fixture()
      %Image{id: loser_id} = image_fixture()

      {:ok, comparison} = Collections.create_comparison(winner_id, loser_id)

      comparison
    end

    test "create_comparison/1 with correct ids creates comparison" do
      %Image{id: winner_id} = image_fixture()
      %Image{id: loser_id} = image_fixture()

      assert {:ok, %Comparison{} = comparison} = Collections.create_comparison(winner_id, loser_id)
      assert comparison.winner_id == winner_id
      assert comparison.loser_id == loser_id
    end

    test "get_comparison!/1 returns the comparison with given id" do
      comparison = comparison_fixture()
      assert Collections.get_comparison!(comparison.id) == comparison
    end

    test "list_image_comparisons returns empty comparisons for image with no comparisons" do
      image = image_fixture()
      assert %{lost_against: [], won_against: []} = Collections.list_image_comparisons!(image.id);
    end
  end
end
