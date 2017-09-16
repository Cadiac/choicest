defmodule Choicest.Core do
  @moduledoc """
  The Collections context.
  """

  import Ecto.Query, warn: false
  alias Choicest.Repo

  alias Choicest.Model.Collection
  alias Choicest.Model.Image
  alias Choicest.Model.Comparison

  import Comeonin.Argon2, only: [checkpw: 2, dummy_checkpw: 0]

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images(collection_id)
      [%Image{}, ...]

  """
  def list_images(collection_id) do
    Repo.all(
      from i in Image,
      where: i.collection_id == ^collection_id,
      select: i
    )
  end

  @doc """
  Gets a single image in collection.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(collection_id, image_id)
      %Image{}

      iex> get_image!(collection_id, bad_image_id)
      ** (Ecto.NoResultsError)

  """
  def get_image!(collection_id, image_id) do
    Repo.get_by!(Image, %{id: image_id, collection_id: collection_id})
  end

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(collection_id, %{field: value})
      {:ok, %Image{}}

      iex> create_image(collection_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(collection_id, attrs \\ %{}) do
    collection = get_collection!(collection_id)

    Ecto.build_assoc(collection, :images)
    |> Image.insert_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a presigned url for image upload.
  """
  def create_presigned_url(collection_id, filename) do
    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:put,
                              System.get_env("AWS_S3_COLLECTION_BUCKET"),
                              "#{collection_id}/#{filename}",
                              [ expires_in: 600, query_params: %{"Content-Type": "image/jpeg", "Content-Length": 91234} ])
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%Image{} = image) do
    Image.changeset(image, %{})
  end

  @doc """
  Creates comparison between `winner_id` and `loser_id` images.

  ## Examples

      iex> create_comparison(collection_id, winner_id, loser_id)
      {:ok, %Comparison{}}

      iex> create_comparison(inactive_collection_id, winner_id, loser_id)
      {:error, "Voting is not active"}

      iex> create_comparison(collection_id, bad_winner_id, bad_loser_id)
      ** (Ecto.NoResultsError)

  """
  def create_comparison(collection_id, winner_id, loser_id) do
    collection = get_collection!(collection_id)

    if collection.voting_active do
      winner = get_image!(collection_id, winner_id)
      loser = get_image!(collection_id, loser_id)

      comparison = Ecto.build_assoc(winner, :wins)
      comparison = Ecto.build_assoc(loser, :losses, Map.from_struct comparison)
      comparison = Ecto.build_assoc(collection, :comparisons, Map.from_struct comparison)

      case Repo.insert(comparison) do
        {:ok, comparison} ->
          {:ok, comparison |> Repo.preload(:winner) |> Repo.preload(:loser)}
      end
    else
      {:error, "Voting is not active"}
    end
  end

  @doc """
  Gets single comparison by id

  ## Examples

      iex> get_comparison!(collection_id, comparison_id)
      {:ok, %Comparison{}}

      iex> get_comparison!(collection_id, bad_comparison_id)
      ** (Ecto.NoResultsError)

  """
  def get_comparison!(collection_id, comparison_id) do
    Repo.get_by!(Comparison, %{id: comparison_id, collection_id: collection_id})
    |> Repo.preload(:winner)
    |> Repo.preload(:loser)
  end

  @doc """
  Gets a list of comparisons on image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> list_image_comparisons!(collection_id, image_id)
      %{lost_against: [%Comparison{}, ...], won_against: [%Comparison{}, ...]}

      iex> list_image_comparisons!(collection_id, bad_image_id)
      %{lost_against: [], won_against: []}

  """
  def list_image_comparisons!(collection_id, image_id) do
    won_against = Repo.all(
      from c in Comparison,
        join: w in assoc(c, :winner),
      where: w.collection_id == ^collection_id,
      where: w.id == ^image_id,
      select: c,
      preload: [:loser]
    )
    lost_against = Repo.all(
      from c in Comparison,
        join: l in assoc(c, :loser),
      where: l.collection_id == ^collection_id,
      where: l.id == ^image_id,
      select: c,
      preload: [:winner]
    )

    %{won_against: won_against, lost_against: lost_against}
  end

  @doc """
  Returns the list of collections.

  ## Examples

      iex> list_collections()
      [%Collection{}, ...]

  """
  def list_collections do
    Repo.all(Collection)
  end

  @doc """
  Gets a single collection.

  Raises `Ecto.NoResultsError` if the Collection does not exist.

  ## Examples

      iex> get_collection!(123)
      %Collection{}

      iex> get_collection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collection!(id), do: Repo.get!(Collection, id)

  @doc """
  Gets a single collection by slug.

  Raises `Ecto.NoResultsError` if the Collection does not exist.

  ## Examples

      iex> get_collection_by_slug!("foo-bar-baz")
      %Collection{}

      iex> get_collection_by_slug!("bar-foo")
      ** (Ecto.NoResultsError)

  """
  def get_collection_by_slug!(slug) do
    Repo.one!(
      from c in Collection,
      where: c.slug == ^slug
    )
  end

  @doc """
  Creates a collection.

  ## Examples

      iex> create_collection(%{field: value})
      {:ok, %Collection{}}

      iex> create_collection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collection(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a collection.

  ## Examples

      iex> update_collection(collection, %{field: new_value})
      {:ok, %Collection{}}

      iex> update_collection(collection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Collection.

  ## Examples

      iex> delete_collection(collection)
      {:ok, %Collection{}}

      iex> delete_collection(collection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection changes.

  ## Examples

      iex> change_collection(collection)
      %Ecto.Changeset{source: %Collection{}}

  """
  def change_collection(%Collection{} = collection) do
    Collection.changeset(collection, %{})
  end

  @doc """
  Checks if password matches collection with password.

  ## Examples

      iex> verify_collection_credentials(123, "hunter2")
      {:ok, %Collection{}}

      iex> verify_collection_credentials(666, "hunter2")
      {:error, reason}

  """
  def verify_collection_credentials(id, password) when is_number(id) and is_binary(password) do
    with {:ok, collection} <- find_collection_by_id(id),
      do: verify_password(password, collection)
  end

  defp find_collection_by_id(id) when is_number(id) do
    case Repo.get(Collection, id) do
      nil ->
        dummy_checkpw()
        {:error, "Collection '#{id}' not found"}
      collection ->
        {:ok, collection}
    end
  end


  defp verify_password(password, %Collection{} = collection) when is_binary(password) do
    if checkpw(password, collection.password_hash) do
      {:ok, collection}
    else
      {:error, :invalid_password}
    end
  end

end
