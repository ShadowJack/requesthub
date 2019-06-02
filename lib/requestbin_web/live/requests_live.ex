defmodule RequestbinWeb.RequestsLive do
  @moduledoc """
  Live view for the list of requests
  """
  use Phoenix.LiveView

  @doc """
  Is called during the first load
  and once the client establishes the connection over socket
  """
  def mount(%{bin: bin}, socket) do
    {:ok, assign(socket, bin: bin)}
  end

  @doc """
  Render the view
  """
  def render(assigns) do
    ~L"""
    <h4>Latest requests for /<%= @bin.id %></h4> 
    <%= for {req, id_in_list} <- Enum.with_index(@bin.requests) do %>
      <%= RequestbinWeb.RequestView.render("details.html", req: req, is_collapsed: id_in_list != 0) %>
    <% end %>
    """
  end
end
