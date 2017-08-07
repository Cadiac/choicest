defmodule Choicest.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :name, :string
      add :description, :string
      add :voting_active, :boolean, default: false, null: false

      timestamps()
    end

    alter table(:images) do
      add :collection_id, references(:collections, on_delete: :nothing)
    end

    alter table(:comparisons) do
      add :collection_id, references(:collections, on_delete: :nothing)
    end
  end
end
