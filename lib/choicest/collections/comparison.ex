defmodule Choicest.Collections.Comparison do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Image
  alias Choicest.Collections.Comparison
  alias Choicest.Collections.Collection


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
  end
end
