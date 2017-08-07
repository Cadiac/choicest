defmodule Choicest.ImageTest do
  use Choicest.DataCase

  alias Choicest.Collections

  describe "images" do
    alias Choicest.Collections.Image

    @valid_image_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
    @update_image_attrs %{content_type: "some updated content_type", description: "some updated description", file_size: 43, filename: "some updated filename", url: "some updated url"}
    @invalid_image_attrs %{content_type: nil, description: nil, file_size: nil, filename: nil, url: nil}

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

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Collections.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Collections.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Collections.create_image(@valid_image_attrs)
      assert image.content_type == "some content_type"
      assert image.description == "some description"
      assert image.file_size == 42
      assert image.filename == "some filename"
      assert image.url == "some url"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collections.create_image(@invalid_image_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, image} = Collections.update_image(image, @update_image_attrs)
      assert %Image{} = image
      assert image.content_type == "some updated content_type"
      assert image.description == "some updated description"
      assert image.file_size == 43
      assert image.filename == "some updated filename"
      assert image.url == "some updated url"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Collections.update_image(image, @invalid_image_attrs)
      assert image == Collections.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Collections.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Collections.change_image(image)
    end
  end
end
