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

  pipeline :auth do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureResource
  end

  scope "/", ChoicestWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Non-authenticated.
  scope "/api", ChoicestWeb do
    pipe_through :api

    resources "/collections", CollectionController, only: [:index, :show, :create] do
      resources "/images", ImageController, only: [:index, :show]

      post "/comparisons/", ComparisonController, :create
      get "/comparisons/:id", ComparisonController, :show
      get "/comparisons/results/:image_id", ComparisonController, :results
    end

    get "/collections/by_slug/:slug", CollectionController, :get_by_slug
  end

  # Authenticated
  scope "/api", ChoicestWeb do
    pipe_through :auth

    resources "/collections", CollectionController, only: [:update, :delete] do
      resources "/images", ImageController, only: [:create, :update, :delete]
    end
  end
end
