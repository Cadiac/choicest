defmodule Choicest.ImageTest do
  use Choicest.DataCase

  alias Choicest.Collections

  describe "images" do
    alias Choicest.Collections.Image
    alias Choicest.Collections.Collection

    @valid_image_attrs %{description: "some description", original_filename: "some original_filename", content_type: "image/jpeg", file_size: 42, uploaded_by: "uploaded_by"}
    @update_image_attrs %{description: "some updated description"}
    @invalid_image_attrs %{description: nil, original_filename: nil, content_type: nil, file_size: nil, uploaded_by: nil}

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
      assert image.content_type == @valid_image_attrs.content_type
      assert image.description == @valid_image_attrs.description
      assert image.original_filename == @valid_image_attrs.original_filename
      assert image.file_size == @valid_image_attrs.file_size
      assert image.uploaded_by == @valid_image_attrs.uploaded_by

      region = System.get_env("AWS_REGION")
      bucket = System.get_env("AWS_S3_COLLECTION_BUCKET")

      assert "https://s3-#{region}.amazonaws.com/#{bucket}/#{collection_id}/#{image.filename}" == image.url
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
      assert image.description == @update_image_attrs.description
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
