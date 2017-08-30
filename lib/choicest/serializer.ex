defmodule Choicest.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Choicest.Repo
  alias Choicest.Collections.Collection

  def for_token(collection = %Collection{}), do: { :ok, "Collection:#{collection.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("Collection:" <> id), do: { :ok, Repo.get(Collection, id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
