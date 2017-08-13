defmodule Choicest.Repo.Migrations.ChangeImageMetadata do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :original_filename, :string
      add :uploaded_by, :string
    end
  end
end
