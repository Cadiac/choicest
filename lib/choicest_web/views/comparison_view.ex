defmodule ChoicestWeb.ComparisonView do
  use ChoicestWeb, :view
  alias ChoicestWeb.ComparisonView
  alias ChoicestWeb.ImageView

  def render("index.json", %{comparison_results: comparisons}) do
    %{won_against: render_many(comparisons.won_against, ComparisonView, "wins.json"),
      lost_against: render_many(comparisons.lost_against, ComparisonView, "losses.json")}
  end

  def render("wins.json", %{comparison: comparison}) do
    %{id: comparison.id,
      timestamp: comparison.inserted_at,
      image: render_one(comparison.loser, ImageView, "image.json")}
  end

  def render("losses.json", %{comparison: comparison}) do
    %{id: comparison.id,
      timestamp: comparison.inserted_at,
      image: render_one(comparison.winner, ImageView, "image.json")}
  end

  def render("show.json", %{comparison: comparison}) do
    render_one(comparison, ComparisonView, "comparison.json")
  end

  def render("comparison.json", %{comparison: comparison}) do
    %{id: comparison.id,
      inserted_at: comparison.inserted_at,
      loser: render_one(comparison.loser, ImageView, "image.json"),
      winner: render_one(comparison.winner, ImageView, "image.json")}
  end
end
