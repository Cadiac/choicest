defmodule Choicest.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :url, :string
      add :filename, :string
      add :description, :string
      add :content_type, :string
      add :file_size, :integer

      timestamps()
    end

  end
end
