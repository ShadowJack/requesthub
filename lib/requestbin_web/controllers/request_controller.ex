defmodule RequestbinWeb.RequestController do
  use RequestbinWeb, :controller

  alias Requestbin.Bins
  alias Requestbin.Bins.Request

  plug :fetch_session when action in [:create]
  plug :fetch_flash when action in [:create]

  def index(conn, %{"bin_id" => bin_id}) do
    reqs = Bins.list_requests(bin_id)

    render(conn, "index.html", reqs: reqs, bin_id: bin_id)
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

  def delete(conn, %{"bin_id" => bin_id, "req_id" => req_id}) do
    IO.puts("Deleting #{req_id}")
    with %Request{} = req <- Bins.get_request(bin_id, req_id),
         {:ok, _} <- Bins.delete_request(req) do
      put_flash_and_redirect_to_index(conn, bin_id, :info, "The request has been deleted")
    else
      nil ->
        put_flash_and_redirect_to_index(conn, bin_id, :error, "Sorry, request with id=\"#{req_id}\" is not found.")
      {:error, _} ->
        put_flash_and_redirect_to_index(conn, bin_id, :error, "Sorry, an error has occured while deleting the request with id=\"#{req_id}\". Please try again later.")
    end
  end

  # Set flash message and redirect to the list of requests
  @spec put_flash_and_redirect_to_index(Plug.Conn.t, String.t, atom, String.t) :: Plug.Conn.t
  defp put_flash_and_redirect_to_index(conn, bin_id, flash_key, flash_message) do
    conn
    |> put_flash(flash_key, flash_message)
    |> redirect(to: request_path(conn, :index, bin_id))
  end
end
