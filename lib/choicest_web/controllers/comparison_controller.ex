defmodule ChoicestWeb.ComparisonController do
  use ChoicestWeb, :controller

  alias Choicest.Core
  alias Choicest.Core.Comparison

  action_fallback ChoicestWeb.FallbackController

  def results(conn, %{"collection_id" => collection_id, "image_id" => image_id}) do
    comparisons = Core.list_image_comparisons!(collection_id, image_id)
    render(conn, "index.json", comparison_results: comparisons)
  end

  def show(conn, %{"collection_id" => collection_id, "id" => id}) do
    comparison = Core.get_comparison!(collection_id, id)
    render(conn, "show.json", comparison: comparison)
  end

  def create(conn, %{"collection_id" => collection_id, "winner_id" => winner_id, "loser_id" => loser_id}) do
    with {:ok, %Comparison{} = comparison} <- Core.create_comparison(collection_id, winner_id, loser_id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", "/api/comparisons/#{comparison.id}")
      |> render("show.json", comparison: comparison)
    end
  end
end
