defmodule RequestbinWeb.RequestController do
  use RequestbinWeb, :controller

  alias Requestbin.Bins
  alias Requestbin.Bins.Request

  plug :fetch_session when action in [:create]
  plug :fetch_flash when action in [:create]
  plug :check_access_allowed

  def index(conn, %{"bin_id" => bin_id}) do
    bin = Bins.get_bin_with_requests(bin_id)
    if bin == nil do
      put_status(conn, :not_found)
    else
      Phoenix.LiveView.Controller.live_render(conn, RequestbinWeb.RequestsLive, session: %{bin: bin})
      # render(conn, "index.html", bin: bin)
    end
  end

  def create(conn, _) do
    case Bins.create_request(conn) do
      {:ok, req} ->
        # notify all active LiveViews about the new request
        RequestbinWeb.Endpoint.broadcast(
          RequestbinWeb.RequestsLive.topic(req.bin_id), 
          RequestbinWeb.RequestsLive.request_created_event(), 
          %{request: req})
        conn
        |> put_flash(:info, "Request has been created successfully.")
        #TODO: redirect only if the request is made from browser
        # otherwise - return 201 status and the link to /bins/:bin_id/requests
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
    case Bins.delete_request(bin_id, req_id) do
      {:ok, _} -> 
        put_flash_and_redirect_to_index(conn, bin_id, :info, "The request has been deleted")
      {:error, :not_found} ->
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

  defp check_access_allowed(conn, _) do
    with bin_id <- Map.get(conn.path_params, "bin_id"),
         true <- Bins.access_allowed?(bin_id, Guardian.Plug.current_resource(conn)) do
      conn
    else
      _ ->
        conn
        |> put_flash(:error, "Access denied")
        |> put_status(403)
        |> halt()
    end
  end
end
