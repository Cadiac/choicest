defmodule Choicest.CollectionsTest do
  use Choicest.DataCase

  alias Choicest.Collections

  describe "collections" do
    alias Choicest.Collections.Collection

    @valid_attrs %{"description" => "some description", "name" => "some name", "voting_active" => true}
    @update_attrs %{"description" => "some updated description", "name" => "some updated name", "voting_active" => false}
    @invalid_attrs %{"description" => nil, "name" => nil, "voting_active" => nil}

    def collection_fixture(attrs \\ %{}) do
      {:ok, collection} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Collections.create_collection()

      collection
    end

    test "list_collections/0 returns all collections" do
      collection = collection_fixture()
      assert Collections.list_collections() == [collection]
    end

    test "get_collection!/1 returns the collection with given id" do
      collection = collection_fixture()
      assert Collections.get_collection!(collection.id) == collection
    end

    test "get_collection_by_slug!/1 returns the collection with given slug" do
      collection = collection_fixture()
      assert Collections.get_collection_by_slug!(collection.slug) == collection
    end

    test "create_collection/1 with valid data creates a collection" do
      assert {:ok, %Collection{} = collection} = Collections.create_collection(@valid_attrs)
      assert collection.description == @valid_attrs["description"]
      assert collection.name == @valid_attrs["name"]
      assert collection.voting_active == @valid_attrs["voting_active"]
    end

    test "create_collection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collections.create_collection(@invalid_attrs)
    end

    test "update_collection/2 with valid data updates the collection" do
      collection = collection_fixture()
      assert {:ok, collection} = Collections.update_collection(collection, @update_attrs)
      assert %Collection{} = collection
      assert collection.description == @update_attrs["description"]
      assert collection.name == @update_attrs["name"]
      assert collection.voting_active == @update_attrs["voting_active"]
    end

    test "update_collection/2 with invalid data returns error changeset" do
      collection = collection_fixture()
      assert {:error, %Ecto.Changeset{}} = Collections.update_collection(collection, @invalid_attrs)
      assert collection == Collections.get_collection!(collection.id)
    end

    test "delete_collection/1 deletes the collection" do
      collection = collection_fixture()
      assert {:ok, %Collection{}} = Collections.delete_collection(collection)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_collection!(collection.id) end
    end

    test "change_collection/1 returns a collection changeset" do
      collection = collection_fixture()
      assert %Ecto.Changeset{} = Collections.change_collection(collection)
    end
  end
end
