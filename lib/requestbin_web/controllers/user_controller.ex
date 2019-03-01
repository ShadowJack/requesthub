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
      |> Guardian.Plug.sign_in(Requestbin.Users.Guardian, user)
      |> redirect(to: homepage_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => user_id}) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_flash(:error, "Please log-in")
        |> redirect(to: session_path(conn, :new))
      user ->
        if (to_string(user.id) != user_id) do
          conn
          |> put_flash(:error, "Access is denied")
          |> redirect(to: homepage_path(conn, :index))
        else
          render(conn, "edit.html", user: Users.change_user(user), user_id: user.id)
        end
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

end
