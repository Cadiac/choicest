defmodule Choicest.Repo.Migrations.AddPasswordCollections do
  use Ecto.Migration

  def change do
    alter table(:collections) do
      add :password_hash, :string
    end
  end
end
