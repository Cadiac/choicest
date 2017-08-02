defmodule Choicest.Repo.Migrations.CreateComparisons do
  use Ecto.Migration

  def change do
    create table(:comparisons) do
      add :session_id, :string
      add :winner_id, references(:images, on_delete: :nothing)
      add :loser_id, references(:images, on_delete: :nothing)

      timestamps()
    end

    create index(:comparisons, [:winner_id])
    create index(:comparisons, [:loser_id])
  end
end
