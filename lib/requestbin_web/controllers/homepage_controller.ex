defmodule RequestbinWeb.HomepageController do
  use RequestbinWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
