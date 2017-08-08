defmodule Choicest.ImageTest do
  use Choicest.DataCase

  alias Choicest.Collections

  describe "images" do
    alias Choicest.Collections.Image
    alias Choicest.Collections.Collection

    @valid_image_attrs %{content_type: "some content_type", description: "some description", file_size: 42, filename: "some filename", url: "some url"}
    @update_image_attrs %{content_type: "some updated content_type", description: "some updated description", file_size: 43, filename: "some updated filename", url: "some updated url"}
    @invalid_image_attrs %{content_type: nil, description: nil, file_size: nil, filename: nil, url: nil}

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

    test "list_images/1 returns all images" do
      %Collection{id: collection_id} = collection_fixture()

      image = image_fixture(collection_id)
      assert Collections.list_images(collection_id) == [image]
    end

    test "get_image!/2 returns the image with given id" do
      %Collection{id: collection_id} = collection_fixture()

      image = image_fixture(collection_id)
      assert Collections.get_image!(collection_id, image.id) == image
    end

    test "create_image/2 with valid data creates a image" do
      %Collection{id: collection_id} = collection_fixture()

      assert {:ok, %Image{} = image} = Collections.create_image(collection_id, @valid_image_attrs)
      assert image.content_type == "some content_type"
      assert image.description == "some description"
      assert image.file_size == 42
      assert image.filename == "some filename"
      assert image.url == "some url"
    end

    test "create_image/1 with invalid data returns error changeset" do
      %Collection{id: collection_id} = collection_fixture()

      assert {:error, %Ecto.Changeset{}} = Collections.create_image(collection_id, @invalid_image_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      %Collection{id: collection_id} = collection_fixture()

      image = image_fixture(collection_id)
      assert {:ok, image} = Collections.update_image(image, @update_image_attrs)
      assert %Image{} = image
      assert image.content_type == "some updated content_type"
      assert image.description == "some updated description"
      assert image.file_size == 43
      assert image.filename == "some updated filename"
      assert image.url == "some updated url"
      assert image.collection_id == collection_id
    end

    test "update_image/2 with invalid data returns error changeset" do
      %Collection{id: collection_id} = collection_fixture()

      image = image_fixture(collection_id)
      assert {:error, %Ecto.Changeset{}} = Collections.update_image(image, @invalid_image_attrs)
      assert image == Collections.get_image!(collection_id, image.id)
    end

    test "delete_image/1 deletes the image" do
      %Collection{id: collection_id} = collection_fixture()

      image = image_fixture(collection_id)
      assert {:ok, %Image{}} = Collections.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_image!(collection_id, image.id) end
    end

    test "change_image/1 returns a image changeset" do
      %Collection{id: collection_id} = collection_fixture()

      image = image_fixture(collection_id)
      assert %Ecto.Changeset{} = Collections.change_image(image)
    end
  end
end
