defmodule Choicest.ComparisonsTest do
  use Choicest.DataCase

  alias Choicest.Contestants

  describe "comparisons" do
    alias Choicest.Contestants.Image
    alias Choicest.Contestants.Comparison

    @valid_image_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_image_attrs)
        |> Contestants.create_image()

      image
    end

    def comparison_fixture() do
      %Image{id: winner_id} = image_fixture()
      %Image{id: loser_id} = image_fixture()

      {:ok, comparison} = Contestants.create_comparison(winner_id, loser_id)

      comparison
    end

    test "create_comparison/1 with correct ids creates comparison" do
      %Image{id: winner_id} = image_fixture()
      %Image{id: loser_id} = image_fixture()

      assert {:ok, %Comparison{} = comparison} = Contestants.create_comparison(winner_id, loser_id)
      assert comparison.winner_id == winner_id
      assert comparison.loser_id == loser_id
    end

    test "get_comparison!/1 returns the comparison with given id" do
      comparison = comparison_fixture()
      assert Contestants.get_comparison!(comparison.id) == comparison
    end

    test "list_image_comparisons returns empty comparisons for image with no comparisons" do
      image = image_fixture()
      assert %{lost_against: [], won_against: []} = Contestants.list_image_comparisons!(image.id);
    end
  end
end
