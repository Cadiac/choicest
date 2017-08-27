defmodule Choicest.Repo.Migrations.AddUniqueIndexName do
  use Ecto.Migration

  def change do
    create unique_index(:collections, [:name])
  end
end
