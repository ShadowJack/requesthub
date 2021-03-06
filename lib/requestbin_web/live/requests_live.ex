defmodule RequestbinWeb.RequestsLive do
  @moduledoc """
  Live view for the list of requests
  """
  use Phoenix.LiveView
  alias Requestbin.Bins
  alias Requestbin.Bins.{Bin, Request}
  alias RequestbinWeb.Presenters.RequestPresenter

  @request_deleted_event "request_deleted"
  @request_created_event "request_created"

  ##
  # LiveView implementation

  @doc """
  Is called during the first load
  and once the client establishes the connection over socket
  """
  def mount(%{bin: bin}, socket) do
    # subscribe to a PubSub topic in order to receive 
    # the bin updates later
    RequestbinWeb.Endpoint.subscribe(topic(bin.id))
    requests = 
      bin.requests 
      |> Enum.map(fn r -> RequestPresenter.build(r) end)
      |> uncollapse_first_request()
    {:ok, assign(socket, bin_id: bin.id, requests: requests)}
  end

  @doc """
  Render the view
  """
  def render(assigns) do
    ~L"""
    <h4>Latest requests for /<%= @bin_id %></h4> 
    <%= for req <- @requests do %>
      <%= RequestbinWeb.RequestView.render("details.html", req: req.request, is_collapsed: req.is_collapsed) %>
    <% end %>
    """
  end

  @doc """
  Handle request deletion
  """
  def handle_event("delete_request", req_id, socket) do
    # Do not check if access is allowed, because the client can 
    # set some wrong req_id, but cannot change the bin_id. (Is it true?)
    case Bins.delete_request(socket.assigns.bin_id, req_id) do
      {:ok, _} ->
        # Notify other related LiveViews about the changes
        RequestbinWeb.Endpoint.broadcast_from(
          self(), 
          topic(socket.assigns.bin_id), 
          @request_deleted_event, 
          %{request_id: req_id} 
        )
        # Update the current LiveView
        requests = requests_after_removal(socket.assigns.requests, req_id)
        {:noreply, assign(socket, :requests, requests)}
      {:error, :not_found} -> 
        {:stop, 
          socket
          |> put_flash(:error, "Sorry, request with id=\"#{req_id}\" is not found.")
          |> redirect(to: RequestbinWeb.Router.Helpers.request_path(RequestbinWeb.Endpoint, :index, socket.assigns.bin_id))
        }
      {:error, _} ->
        {:stop,
          socket
          |> put_flash(:error, "Sorry, an error has occured while deleting the request with id=\"#{req_id}\". Please try again later.")
          |> redirect(to: RequestbinWeb.Router.Helpers.request_path(RequestbinWeb.Endpoint, :index, socket.assigns.bin_id))
        }
    end
  end

  @doc """
  Handle collapse/uncollapse event
  """
  def handle_event("toggle_collapse", req_id, socket) do

    requests = socket.assigns.requests |> Enum.map(fn r -> 
      if (r.request.id == req_id) do
        %RequestPresenter{r | is_collapsed: !r.is_collapsed}
      else
        r
      end
    end)
    {:noreply, assign(socket, :requests, requests)}
  end


  # handle the deletion message from the PubSub
  def handle_info(%{event: @request_deleted_event, payload: %{request_id: req_id}}, socket) do
    requests = requests_after_removal(socket.assigns.requests, req_id)
    {:noreply, assign(socket, :requests, requests)}
  end
 
  # handle the creation message from the PubSub
  def handle_info(%{event: @request_created_event, payload: %{request: req}}, socket) do
    requests = requests_after_creation(socket.assigns.requests, req)
    {:noreply, assign(socket, :requests, requests)}
  end

  ##
  # Public API
  
  @doc """
  A topic name for the current bin
  """ 
  @spec topic(Bin.bin_id) :: String.t
  def topic(bin_id) do
    "updated_requests:#{bin_id}"
  end

  @doc """
  An event name to be used once a new request is arrived
  """
  @spec request_created_event() :: String.t
  def request_created_event() do
    @request_created_event
  end

  @doc """
  An event name to be used once some request is deleted
  """
  @spec request_deleted_event() :: String.t
  def request_deleted_event() do
    @request_deleted_event
  end


  ## Helpers
  #

  # update the list of requests after a new request is created
  @spec requests_after_creation([RequestPresenter.t], Request.t) :: [RequestPresenter.t]
  defp requests_after_creation(requests, new_req) do
    if Enum.any?(requests, fn r -> r.request.id == new_req.id end) do
      requests
    else
      [RequestPresenter.build(new_req) | requests]
    end
  end

  # update the list of requests after one of requests was deleted
  @spec requests_after_removal([RequestPresenter.t], Request.request_id) :: [RequestPresenter.t]
  defp requests_after_removal(requests, deleted_req_id) do
    requests
    |> Enum.reject(fn r -> r.request.id == deleted_req_id end)
  end

  @spec uncollapse_first_request([RequestPresenter.t]) :: [RequestPresenter.t]
  defp uncollapse_first_request([]), do: []
  defp uncollapse_first_request([head | tail]) do
    [%RequestPresenter{head | is_collapsed: false} | tail]
  end

end
