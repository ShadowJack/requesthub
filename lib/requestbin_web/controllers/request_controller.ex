defmodule RequestbinWeb.RequestController do
  use RequestbinWeb, :controller

  alias Requestbin.Bins
  alias Requestbin.Bins.Request

  plug :fetch_session when action in [:create]
  plug :fetch_flash when action in [:create]

  def index(conn, _params) do
    conn
    # requests = Bins.list_requests()
    # render(conn, "index.html", requests: requests)
  end

  def create(conn, _) do
    case Bins.create_request(conn) do
      {:ok, req} ->
        conn
        |> put_flash(:info, "Request has been created successfully.")
        |> redirect(to: request_path(conn, :show, req.bin_id, req.id))
      {:error, %Ecto.Changeset{errors: errors}} ->
        conn
        |> put_flash(:error, Request.build_error_message(errors))
        |> redirect(to: "/")
    end
  end

  def show(conn, %{"bin_id" => bin_id, "req_id" => req_id}) do
    case Bins.get_request(bin_id, req_id) do
      %Request{} = req ->
        conn
        |> render("show.html", req: req)
      nil ->
        conn
        |> put_flash(:error, "Sorry, request with id=\"#{req_id}\" is not found.")
        |> redirect(to: request_path(conn, :index, bin_id))
    end
  end
end
