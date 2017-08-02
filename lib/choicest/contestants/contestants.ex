defmodule Choicest.Contestants do
  @moduledoc """
  The Contestants context.
  """

  import Ecto.Query, warn: false
  alias Choicest.Repo

  alias Choicest.Contestants.Image
  alias Choicest.Contestants.Comparison

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Repo.all(Image)
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Image, id)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
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
    |> Image.changeset(attrs)
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
  Gets a list of comparisons on image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> list_image_comparisons!(123)
      %{lost_against: [%Choicest.Contestants.Comparison{}, ...], won_against: [%Choicest.Contestants.Comparison{}, ...]}

      iex> list_image_comparisons!(456)
      %{lost_against: [], won_against: []}

  """
  def list_image_comparisons!(id) do
    won_against = Repo.all(
      from c in Comparison,
        join: w in assoc(c, :winner),
      where: w.id == ^id,
      select: c,
      preload: [:loser]
    )
    lost_against = Repo.all(
      from c in Comparison,
        join: l in assoc(c, :loser),
      where: l.id == ^id,
      select: c,
      preload: [:winner]
    )

    %{won_against: won_against, lost_against: lost_against}
  end
end
