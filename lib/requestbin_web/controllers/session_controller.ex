defmodule RequestbinWeb.SessionController do
  @moduledoc """
  Manage login/logout
  """
  use RequestbinWeb, :controller
  alias Requestbin.Users
  alias Requestbin.Users.User

  def new(conn, _) do
    curr_user = Guardian.Plug.current_resource(conn)
    if curr_user do
      redirect(conn, to: homepage_path(conn, :index))
    else
      user = Users.change_user(%User{})
      render(conn, "new.html", user: user)
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Users.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "Welcome back!")
        |> Guardian.Plug.sign_in(Requestbin.Users.Guardian, user)
        |> redirect(to: homepage_path(conn, :index))
      {:error, reason} ->
        conn
        |> put_flash(:error, to_string(reason))
        |> new(%{})
    end
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out(Requestbin.Users.Guardian, [])
    |> redirect(to: homepage_path(conn, :index))
  end
end
