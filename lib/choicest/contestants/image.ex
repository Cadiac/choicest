defmodule Choicest.Contestants.Image do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Contestants.Image


  schema "images" do
    field :content_type, :string
    field :description, :string
    field :file_size, :integer
    field :filename, :string
    field :url, :string

    timestamps()

    has_many :wins, Comparison
    has_many :losses, Comparison
  end

  @doc false
  def changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:url, :filename, :description, :content_type, :file_size])
    |> validate_required([:url, :filename, :description, :content_type, :file_size])
  end
end
