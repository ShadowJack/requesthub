defmodule RequestbinWeb.Router do
  use RequestbinWeb, :router

  pipeline :browser do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Jason
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :raw_request do
    plug :fetch_session
    plug :fetch_flash
  end

  # specific action to save any request that is coming to the bin
  match :*, "/bins/:bin_id", RequestbinWeb.RequestController, :create

  scope "/", RequestbinWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomepageController, :index

    # bins
    post "/bins", BinController, :create

    #  bin requests
    get "/bins/:bin_id/requests/:req_id", RequestController, :show
    get "/bins/:bin_id/requests", RequestController, :index
  end

end
