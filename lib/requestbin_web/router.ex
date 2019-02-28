defmodule RequestbinWeb.Router do
  use RequestbinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Requestbin.Users.Pipeline
  end

  # specific action to save any request that is coming to the bin
  match :*, "/bins/:bin_id", RequestbinWeb.RequestController, :create

  scope "/", RequestbinWeb do
    pipe_through [:browser, :auth]

    get "/", HomepageController, :index

    # bins
    post "/bins", BinController, :create

    #  bin requests
    get "/bins/:bin_id/requests", RequestController, :index
    get "/bins/:bin_id/requests/:req_id", RequestController, :show
    delete "/bins/:bin_id/requests/:req_id", RequestController, :delete

    # users
    resources "/users", UserController, except: [:index, :delete]

    # login/logout
    get "/login", SessionController, :new
    post "/login", SessionController, :login
    post "/logout", SessionController, :logout

    # catch-all that will display 404 error
    match :*, "/*path", HomepageController, :not_found
  end


end
