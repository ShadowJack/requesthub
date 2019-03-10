defmodule RequestbinWeb.HomepageController do
  use RequestbinWeb, :controller

  alias Requestbin.Bins.Bin

  def index(conn, _params) do
    render conn, "index.html", 
      session_bins: get_bins_from_session(conn), 
      user_bins: get_bins_for_user(conn)
  end

  def not_found(conn, _params) do
    render conn, "404.html"
  end

  @spec get_bins_from_session(Conn.t) :: [Bin.t]
  defp get_bins_from_session(conn) do
    case get_session(conn, :bins) do
      nil -> []
      bins -> bins |> Enum.take(5) |> Requestbin.Bins.get_bins()
    end
  end

  @spec get_bins_for_user(Conn.t) :: [Bin.t]
  defp get_bins_for_user(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil -> []
      user -> Requestbin.Users.list_bins(user)
    end
  end
end
