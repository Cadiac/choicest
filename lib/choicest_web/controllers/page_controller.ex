defmodule ChoicestWeb.PageController do
  use ChoicestWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
