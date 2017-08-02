defmodule ChoicestWeb.ComparisonController do
  use ChoicestWeb, :controller

  alias Choicest.Contestants

  action_fallback ChoicestWeb.FallbackController

  def index(conn, %{"image_id" => image_id}) do
    comparisons = Contestants.list_image_comparisons!(image_id)
    render(conn, "index.json", comparisons: comparisons)
  end
end
