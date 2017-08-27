defmodule Choicest.Collections.Collection.CollectionSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug, always_change: true
end

defmodule Choicest.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Image
  alias Choicest.Collections.Comparison
  alias Choicest.Collections.Collection
  alias Choicest.Collections.Collection.CollectionSlug

  schema "collections" do
    field :description, :string
    field :name, :string
    field :slug, CollectionSlug.Type
    field :voting_active, :boolean, default: false

    timestamps()

    has_many :images, Image, foreign_key: :collection_id
    has_many :comparisons, Comparison, foreign_key: :collection_id
  end

  @doc false
  def changeset(%Collection{} = collection, attrs) do
    collection
    |> cast(attrs, [:name, :description, :voting_active])
    |> validate_required([:name, :voting_active])
    |> validate_length(:name, min: 1, max: 30)
    |> unique_constraint(:name)
    |> CollectionSlug.maybe_generate_slug
    |> CollectionSlug.unique_constraint
  end
end
