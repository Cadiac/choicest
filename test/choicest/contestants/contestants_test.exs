defmodule Choicest.ContestantsTest do
  use Choicest.DataCase

  alias Choicest.Contestants

  describe "images" do
    alias Choicest.Contestants.Image
    alias Choicest.Contestants.Comparison

    @valid_image_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
    @update_image_attrs %{content_type: "some updated content_type", description: "some updated description", file_size: 43, filename: "some updated filename", url: "some updated url"}
    @invalid_image_attrs %{content_type: nil, description: nil, file_size: nil, filename: nil, url: nil}

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

      {:ok, comparison} = Contestants.create_comparison(%{loser_id: loser_id, winner_id: winner_id})

      comparison
    end

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Contestants.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Contestants.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Contestants.create_image(@valid_image_attrs)
      assert image.content_type == "some content_type"
      assert image.description == "some description"
      assert image.file_size == 42
      assert image.filename == "some filename"
      assert image.url == "some url"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contestants.create_image(@invalid_image_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, image} = Contestants.update_image(image, @update_image_attrs)
      assert %Image{} = image
      assert image.content_type == "some updated content_type"
      assert image.description == "some updated description"
      assert image.file_size == 43
      assert image.filename == "some updated filename"
      assert image.url == "some updated url"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Contestants.update_image(image, @invalid_image_attrs)
      assert image == Contestants.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Contestants.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Contestants.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Contestants.change_image(image)
    end

    test "create_comparison/1 with correct ids creates comparison" do
      %Image{id: winner_id} = image_fixture()
      %Image{id: loser_id} = image_fixture()

      comparison_attrs = %{winner_id: winner_id, loser_id: loser_id}
      assert {:ok, %Comparison{} = comparison} = Contestants.create_comparison(comparison_attrs)
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
