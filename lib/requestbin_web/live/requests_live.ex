defmodule RequestbinWeb.RequestsLive do
  @moduledoc """
  Live view for the list of requests
  """
  use Phoenix.LiveView
  alias Requestbin.Bins
  alias Requestbin.Bins.Bin

  @doc """
  Is called during the first load
  and once the client establishes the connection over socket
  """
  def mount(%{bin: bin}, socket) do
    {:ok, assign(socket, bin_id: bin.id, requests: bin.requests)}
  end

  @doc """
  Render the view
  """
  def render(assigns) do
    ~L"""
    <h4>Latest requests for /<%= @bin_id %></h4> 
    <%= for {req, id_in_list} <- Enum.with_index(@requests) do %>
      <%= RequestbinWeb.RequestView.render("details.html", req: req, is_collapsed: id_in_list != 0) %>
    <% end %>
    """
  end

  @doc """
  Handle request deletion
  """
  def handle_event("delete_request", req_id, socket) do
    # Do not check if access is allowed, because the client can 
    # set some wrong req_id, but cannot change the bin_id. (Is it true?)
    with {:ok, _} <- Bins.delete_request(socket.assigns.bin_id, req_id),
         %Bin{requests: requests} <- Bins.get_bin_with_requests(socket.assigns.bin_id) do
      {:noreply, assign(socket, :requests, requests)}
    else
      {:error, :not_found} -> 
        {:noreply, put_flash(socket, :error, "Sorry, request with id=\"#{req_id}\" is not found.")}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Sorry, an error has occured while deleting the request with id=\"#{req_id}\". Please try again later.")}
    end
  end
end
