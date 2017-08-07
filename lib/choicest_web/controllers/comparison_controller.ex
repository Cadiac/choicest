defmodule ChoicestWeb.ComparisonController do
  use ChoicestWeb, :controller

  alias Choicest.Collections
  alias Choicest.Collections.Comparison

  action_fallback ChoicestWeb.FallbackController

  def results(conn, %{"image_id" => image_id}) do
    comparisons = Collections.list_image_comparisons!(image_id)
    render(conn, "index.json", comparison_results: comparisons)
  end

  def create(conn, %{"winner_id" => winner_id, "loser_id" => loser_id}) do
    with {:ok, %Comparison{} = comparison} <- Collections.create_comparison(winner_id, loser_id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", comparison_path(conn, :show, comparison))
      |> render("show.json", comparison: comparison)
    end
  end

  def show(conn, %{"id" => id}) do
    comparison = Collections.get_comparison!(id)
    render(conn, "show.json", comparison: comparison)
  end
end
