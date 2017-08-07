defmodule Choicest.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Collection


  schema "collections" do
    field :description, :string
    field :name, :string
    field :voting_active, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(%Collection{} = collection, attrs) do
    collection
    |> cast(attrs, [:name, :description, :voting_active])
    |> validate_required([:name, :description, :voting_active])
  end
end
