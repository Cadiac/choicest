defmodule ChoicestWeb.Router do
  use ChoicestWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChoicestWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ChoicestWeb do
    pipe_through :api

    resources "/collections", CollectionController, except: [:new, :edit] do
      resources "/images", ImageController, except: [:new, :edit]

      post "/comparisons/", ComparisonController, :create
      get "/comparisons/:id", ComparisonController, :show
      get "/comparisons/results/:image_id", ComparisonController, :results
    end

    get "/collections/by_slug/:slug", CollectionController, :get_by_slug
  end
end
