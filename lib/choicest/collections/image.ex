defmodule Choicest.Collections.Image do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Collections.Image
  alias Choicest.Collections.Comparison
  alias Choicest.Collections.Collection

  alias Choicest.Utils

  schema "images" do
    field :description, :string
    field :url, :string
    field :filename, :string
    field :original_filename, :string
    field :content_type, :string
    field :file_size, :integer
    field :uploaded_by, :string

    timestamps()

    has_many :wins, Comparison, foreign_key: :winner_id
    has_many :losses, Comparison, foreign_key: :loser_id
    belongs_to :collection, Collection
  end

  @doc false
  def changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:description, :url, :filename, :original_filename, :content_type, :file_size, :uploaded_by])
  end

  def insert_changeset(%Image{} = image, attrs) do
    region = System.get_env("AWS_REGION")
    bucket = System.get_env("AWS_S3_COLLECTION_BUCKET")
    filename = Utils.random_string(16)

    image
    |> changeset(attrs)
    |> validate_required([:original_filename, :content_type, :file_size, :uploaded_by])
    |> validate_inclusion(:content_type, ["image/jpeg", "image/png", "image/gif"])
    |> put_change(:filename, filename)
    |> put_change(:url, "https://s3-#{region}.amazonaws.com/#{bucket}/#{image.collection_id}/#{filename}")
  end

  def update_changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
