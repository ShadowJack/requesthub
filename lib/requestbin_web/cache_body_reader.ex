defmodule RequestbinWeb.CacheBodyReader do
  @moduledoc """
  Copy the body of the request into a `raw_body` assign
  to be used later. Long bodies are truncated.
  """
  def read_body(conn, opts) do
    opts = Keyword.put(opts, :length, Requestbin.Bins.Request.max_body_length_in_bytes())
    {body, conn} = case Plug.Conn.read_body(conn, opts) do
      {:ok, body, conn} -> {body, conn}
      {:more, body, conn} -> {body, conn}
    end
    conn = update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
    {:ok, body, conn}
  end
end
