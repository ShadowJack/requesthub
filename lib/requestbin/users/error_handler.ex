defmodule Requestbin.Users.ErrorHandler do
  @moduledoc """
  Authentication errors handler
  """

  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, to_string(type))
  end
end
