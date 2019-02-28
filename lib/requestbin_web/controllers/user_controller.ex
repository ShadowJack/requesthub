defmodule RequestbinWeb.UserController do
  use RequestbinWeb, :controller

  alias Requestbin.Users
  alias Requestbin.Users.User

  action_fallback RequestbinWeb.FallbackController

  def new(conn, _) do
    user = Users.change_user(%User{})
    render(conn, "new.html", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> Guardian.Plug.sign_in(Requestbin.Users.Guardian, user)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user(id)
    render(conn, "show.json", user: user)
  end

  def edit(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        redirect(conn, to: session_path(conn, :new))
      user ->
        render(conn, "edit.html", user: Users.change_user(user))
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

end
