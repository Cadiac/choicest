defmodule Choicest.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Collection
  alias Choicest.Collections.Image
  alias Choicest.Collections.Comparison


  schema "collections" do
    field :description, :string
    field :name, :string
    field :voting_active, :boolean, default: false

    timestamps()

    has_many :images, Image, foreign_key: :collection_id
    has_many :comparisons, Comparison, foreign_key: :collection_id
  end

  @doc false
  def changeset(%Collection{} = collection, attrs) do
    collection
    |> cast(attrs, [:name, :description, :voting_active])
    |> validate_required([:name, :description, :voting_active])
  end
end
