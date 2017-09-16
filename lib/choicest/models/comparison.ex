defmodule Choicest.Core.Comparison do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Core.Image
  alias Choicest.Core.Comparison
  alias Choicest.Core.Collection


  schema "comparisons" do
    field :session_id, :string

    timestamps()

    belongs_to :winner, Image
    belongs_to :loser, Image
    belongs_to :collection, Collection
  end

  @doc false
  def changeset(%Comparison{} = comparison, attrs) do
    comparison
    |> cast(attrs, [:session_id])
    |> foreign_key_constraint(:winner_id)
    |> foreign_key_constraint(:loser_id)
    |> foreign_key_constraint(:collection_id)
  end
end
