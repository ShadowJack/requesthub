defmodule RequestbinWeb.HomepageController do
  use RequestbinWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", bins: get_bins_from_session(conn)
  end

  def not_found(conn, _params) do
    render conn, "404.html"
  end

  @spec get_bins_from_session(Conn.t) :: [String.t]
  defp get_bins_from_session(conn) do
    case get_session(conn, :bins) do
      nil -> []
      bins -> bins
    end
  end
end
