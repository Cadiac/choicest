defmodule Choicest.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Collection
  alias Choicest.Collections.Image
  alias Choicest.Collections.Comparison


  schema "collections" do
    field :description, :string
    field :name, :string
    field :slug, :string
    field :voting_active, :boolean, default: false

    timestamps()

    has_many :images, Image, foreign_key: :collection_id
    has_many :comparisons, Comparison, foreign_key: :collection_id
  end

  @doc false
  def changeset(%Collection{} = collection, attrs) do
    collection
    |> cast(attrs, [:name, :description, :voting_active, :slug])
    |> validate_required([:name, :voting_active, :slug])
    |> unique_constraint(:slug)
  end

  def insert_changeset(%Collection{} = collection, attrs) do
    optional_params = %{"slug" => Choicest.Utils.random_string(16)}

    attrs = Map.merge(optional_params, attrs)

    collection
    |> changeset(attrs)
  end

  def update_changeset(%Collection{} = collection, attrs) do
    collection
    |> changeset(attrs)
  end
end
