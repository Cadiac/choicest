defmodule Choicest.ComparisonsTest do
  use Choicest.DataCase

  alias Choicest.Collections

  describe "comparisons" do
    alias Choicest.Collections.Image
    alias Choicest.Collections.Comparison
    alias Choicest.Collections.Collection

    @valid_image_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
    @valid_collection_attrs %{description: "some description", name: "some name", voting_active: true}

    def collection_fixture(attrs \\ %{}) do
      {:ok, collection} =
        attrs
        |> Enum.into(@valid_collection_attrs)
        |> Collections.create_collection()

      collection
    end

    def image_fixture(collection_id, attrs \\ %{}) do
      attrs = attrs |> Enum.into(@valid_image_attrs)

      {:ok, image} = Collections.create_image(collection_id, attrs)

      image
    end

    def comparison_fixture(collection_id) do
      %Image{id: winner_id} = image_fixture(collection_id)
      %Image{id: loser_id} = image_fixture(collection_id)

      {:ok, comparison} = Collections.create_comparison(collection_id, winner_id, loser_id)

      comparison
    end

    test "create_comparison/1 with correct ids creates comparison" do
      %Collection{id: collection_id} = collection_fixture()

      %Image{id: winner_id} = image_fixture(collection_id)
      %Image{id: loser_id} = image_fixture(collection_id)

      assert {:ok, %Comparison{} = comparison} = Collections.create_comparison(collection_id, winner_id, loser_id)
      assert comparison.winner_id == winner_id
      assert comparison.loser_id == loser_id
    end

    test "get_comparison!/1 returns the comparison with given id" do
      %Collection{id: collection_id} = collection_fixture()

      comparison = comparison_fixture(collection_id)
      assert Collections.get_comparison!(collection_id, comparison.id) == comparison
    end

    test "list_image_comparisons returns empty comparisons for image with no comparisons" do
      %Collection{id: collection_id} = collection_fixture()

      image = image_fixture(collection_id)
      assert %{lost_against: [], won_against: []} = Collections.list_image_comparisons!(collection_id, image.id);
    end
  end
end
