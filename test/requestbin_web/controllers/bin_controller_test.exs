defmodule RequestbinWeb.BinControllerTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Test.{AuthenticationHelpers, Factory}

  test "can create a bin with name", %{conn: conn} do
    conn = post(conn, "/bins", %{"bin" => %{"name" => "Test bin"}})

    url = redirected_to(conn)
    conn = get(conn, url)

    assert html_response(conn, 200) =~ "Test bin"
  end

  test "can create a bin without name", %{conn: conn} do
    conn = post(conn, "/bins")

    url = redirected_to(conn)
    conn = get(conn, url)

    assert html_response(conn, 200) =~ "created"
  end

  test "can create a private bin when signed-in", %{conn: conn} do
    user = Factory.insert(:user)
    conn = conn
      |> AuthenticationHelpers.authenticate(user) 
      |> post("/bins", %{"private" => "true"})

    url = redirected_to(conn)
    conn = get(conn, url)

    assert html_response(conn, 200) =~ "created"
  end

  test "cannot create a private bin when signed-out", %{conn: conn} do
    conn = conn
      |> post("/bins", %{"private" => "true"})

    assert "/" == redirected_to(conn)
    assert get_flash(conn, :error) =~ "wrong"
  end
end
