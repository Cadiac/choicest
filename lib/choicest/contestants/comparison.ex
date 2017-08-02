defmodule Choicest.Contestants.Comparison do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Contestants.Comparison


  schema "comparisons" do
    field :session_id, :string
    field :winner_id, :id
    field :loser_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Comparison{} = comparison, attrs) do
    comparison
    |> cast(attrs, [:session_id])
    |> validate_required([:session_id])
  end
end
