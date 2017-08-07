defmodule Choicest.Collections.Image do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Image
  alias Choicest.Collections.Comparison


  schema "images" do
    field :content_type, :string
    field :description, :string
    field :file_size, :integer
    field :filename, :string
    field :url, :string

    timestamps()

    has_many :wins, Comparison, foreign_key: :winner_id
    has_many :losses, Comparison, foreign_key: :loser_id
  end

  @doc false
  def changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:url, :filename, :description, :content_type, :file_size])
    |> validate_required([:url, :filename, :description, :content_type, :file_size])
  end
end
