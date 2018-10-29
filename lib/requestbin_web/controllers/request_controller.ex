defmodule RequestbinWeb.RequestController do
  use RequestbinWeb, :controller

  alias Requestbin.Bins
  alias Requestbin.Bins.Request

  plug :fetch_session when action in [:create]
  plug :fetch_flash when action in [:create]
  # def index(conn, _params) do
  #   requests = Bins.list_requests()
  #   render(conn, "index.html", requests: requests)
  # end

  def create(conn, _) do
    case Bins.create_request(conn) do
      {:ok, request} ->
        conn
        |> put_flash(:info, "Request has been created successfully.")
        |> redirect(to: request_path(conn, :show, request.bin_id, request.id))
      {:error, %Ecto.Changeset{errors: errors}} ->
        conn
        |> put_flash(:error, Request.build_error_message(errors))
        |> redirect(to: "/")
    end
  end
end
