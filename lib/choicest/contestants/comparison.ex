defmodule Choicest.Contestants.Comparison do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Contestants.Comparison


  schema "comparisons" do
    field :session_id, :string

    timestamps()

    belongs_to :winner, Choicest.Contestants.Image
    belongs_to :loser, Choicest.Contestants.Image
  end

  @doc false
  def changeset(%Comparison{} = comparison, attrs) do
    comparison
    |> cast(attrs, [:session_id])
    |> validate_required([:session_id])
  end
end
