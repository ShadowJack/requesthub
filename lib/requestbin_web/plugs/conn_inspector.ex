defmodule RequestbinWeb.ConnInspector do
  @behaviour Plug

  def init([]), do: []
  def call(conn, []) do
    IO.inspect(conn)
  end
end
