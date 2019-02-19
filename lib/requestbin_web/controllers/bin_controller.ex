defmodule RequestbinWeb.BinController do
  use RequestbinWeb, :controller

  alias Requestbin.Bins

  def create(conn, _) do
    case Bins.create_bin() do
      {:ok, bin} ->
        conn
        |> put_flash(:info, "Bin #{bin.id} is created successfully.")
        |> put_bin_to_session(bin.id)
        |> redirect(to: request_path(conn, :index, bin))
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong, please try again later")
        |> redirect(to: "/")
    end
  end

  @spec put_bin_to_session(Conn.t, String.t) :: Conn.t
  defp put_bin_to_session(conn, bin_id) do
    case get_session(conn, :bins) do
      nil -> put_session(conn, :bins, [bin_id])
      bins -> put_session(conn, :bins, [bin_id | bins])
    end
  end
end
