defmodule ChoicestWeb.SessionController do
  use ChoicestWeb, :controller

  alias Choicest.Core

  def create(conn, %{"session" => %{"id" => id, "password" => password}}) do
    case Core.verify_collection_credentials(id, password) do
      {:ok, collection} ->
        { :ok, jwt, _ } = Guardian.encode_and_sign(collection, :api)
        conn
        |> json(%{ jwt: jwt })
      {:error, _reason} ->
        conn
        |> put_status(401)
        |> json(%{ error: "Invalid collection id or password" })
    end
  end
end
