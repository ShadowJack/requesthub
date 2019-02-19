defmodule RequestbinWeb.BinController do
  use RequestbinWeb, :controller

  alias Requestbin.Bins
  alias Requestbin.Bins.Bin

  def create(conn, _) do
    case Bins.create_bin() do
      {:ok, bin} ->
        conn
        |> put_flash(:info, "Bin #{bin.id} is created successfully.")
        |> redirect(to: request_path(conn, :index, bin))
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong, please try again later")
        |> redirect(to: "/")
    end
  end
end
