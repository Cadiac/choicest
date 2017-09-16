defmodule Choicest.Model.Collection.CollectionSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug, always_change: true
end

defmodule Choicest.Model.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  alias Choicest.Model.Image
  alias Choicest.Model.Comparison
  alias Choicest.Model.Collection
  alias Choicest.Model.Collection.CollectionSlug

  alias Comeonin.Argon2
  alias Choicest.Utils

  schema "collections" do
    field :description, :string
    field :name, :string
    field :slug, CollectionSlug.Type
    field :voting_active, :boolean, default: false

    field :password_hash, :string
    field :password, :string, virtual: true, default: Utils.random_string(16)

    timestamps()

    has_many :images, Image, foreign_key: :collection_id
    has_many :comparisons, Comparison, foreign_key: :collection_id
  end

  @doc false
  def changeset(%Collection{} = collection, attrs) do
    collection
    |> cast(attrs, [:name, :password, :description, :voting_active])
    |> validate_required([:name, :voting_active])
    |> validate_length(:name, min: 1, max: 30)
    |> validate_length(:password, min: 1, max: 255)
    |> hash_password()
    |> unique_constraint(:name)
    |> CollectionSlug.maybe_generate_slug
    |> CollectionSlug.unique_constraint
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset
  defp hash_password(%{valid?: true} = changeset) do
    hashed_password =
      changeset
      |> get_field(:password)
      |> Argon2.hashpwsalt()

    changeset
    |> put_change(:password_hash, hashed_password)
  end
end
