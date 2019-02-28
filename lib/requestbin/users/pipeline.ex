defmodule Requestbin.Users.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :requestbin,
    error_handler: Requestbin.Users.ErrorHandler,
    module: Requestbin.Users.Guardian

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  #
  # Load the user if verification worked
  plug Guardian.Plug.LoadResource, allow_blank: true
end
