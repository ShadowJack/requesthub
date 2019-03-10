defmodule Requestbin.Test.AuthenticationHelpers do
  @moduledoc """
  Authentication helpers
  """

  @signing_opts Plug.Session.init([
    store: :cookie,
    key: "secretkey",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    encrypt: false
  ])

  @doc """
  Authenticate the user
  """
  @spec authenticate(Conn.t, Requestbin.Users.User.t) :: Conn.t
  def authenticate(conn, %Requestbin.Users.User{} = user) do
    conn
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session()
    |> Guardian.Plug.sign_in(Requestbin.Users.Guardian, user)
    |> Guardian.Plug.VerifySession.call([])
  end

end
