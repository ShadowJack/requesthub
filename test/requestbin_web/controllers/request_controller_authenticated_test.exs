defmodule RequestbinWeb.RequestControllerAuthenticatedTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Test.Factory

  @signing_opts Plug.Session.init([
    store: :cookie,
    key: "secretkey",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    encrypt: false
  ])

  setup(ctx) do
    bin = Factory.insert(:private_bin)
    user = List.first(bin.users)

    # authenticate a user
    conn = ctx.conn
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session()
    |> Guardian.Plug.sign_in(Requestbin.Users.Guardian, user)
    |> Guardian.Plug.VerifySession.call([])
    
    [bin_id: bin.id, conn: conn, user: user]
  end

  test "private bin can be accessed by the owner", %{bin_id: bin_id, conn: conn} do
    conn = get(conn, "/bins/#{bin_id}?a=123&b=321")

    assert get_flash(conn, :info) =~ "Request has been created"
    assert %{bin_id: ^bin_id} = redirected_params(conn)
  end

  test "requests in private bin can be accessed by the owner", %{bin_id: bin_id, conn: conn} do
    conn = get(conn, "/bins/#{bin_id}/requests")
    
    assert 200 == conn.status
  end

  test "private bin cannot be accessed by not owner", %{bin_id: bin_id} do
    conn = Phoenix.ConnTest.build_conn()
      |> get("/bins/#{bin_id}?a=123&b=321")

    assert get_flash(conn, :error) =~ "denied"
    assert 403 == conn.status
  end

  test "requests in private bin cannot be accessed by not owner", %{bin_id: bin_id} do
    conn = Phoenix.ConnTest.build_conn()
      |> get("/bins/#{bin_id}/requests")
    
    assert get_flash(conn, :error) =~ "denied"
    assert 403 == conn.status
  end
end
