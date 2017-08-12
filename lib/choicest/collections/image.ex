defmodule Choicest.Collections.Image do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Image
  alias Choicest.Collections.Comparison
  alias Choicest.Collections.Collection


  schema "images" do
    field :content_type, :string
    field :description, :string
    field :file_size, :integer
    field :filename, :string
    field :url, :string

    timestamps()

    has_many :wins, Comparison, foreign_key: :winner_id
    has_many :losses, Comparison, foreign_key: :loser_id
    belongs_to :collection, Collection
  end

  @doc false
  def changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:url, :filename, :description, :content_type, :file_size])
    |> validate_required([:filename, :description, :content_type, :file_size])
  end

  def insert_changeset(%Image{} = image, attrs) do
    region = System.get_env("AWS_REGION")
    bucket = System.get_env("AWS_S3_COLLECTION_BUCKET")
    filename = attrs["filename"]

    image
    |> changeset(attrs)
    |> put_change(:url, "https://s3-#{region}.amazonaws.com/#{bucket}/#{filename}")
  end
end
