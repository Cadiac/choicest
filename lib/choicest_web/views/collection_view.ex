defmodule ChoicestWeb.CollectionView do
  use ChoicestWeb, :view
  alias ChoicestWeb.CollectionView

  def render("index.json", %{collections: collections}) do
    render_many(collections, CollectionView, "collection.json")
  end

  def render("show.json", %{collection: collection}) do
    render_one(collection, CollectionView, "collection.json")
  end

  def render("collection.json", %{collection: collection}) do
    %{id: collection.id,
      slug: collection.slug,
      name: collection.name,
      description: collection.description,
      voting_active: collection.voting_active}
  end
end
