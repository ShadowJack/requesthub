defmodule RequestbinWeb.SettingControllerTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Test.{AuthenticationHelpers, Factory}
  alias RequestbinWeb.{Endpoint, SettingsLive}

  describe "for unsigned user" do
    test "default settings are created when they are requested for the first time", %{conn: conn} do
      # {:ok, view, html} = mount(Endpoint, SettingsLive, session: %{settings: nil})
      # conn = get(conn, "/settings")

      #TODO: check the contents of the session
      # ensure that it contains current settings
      # TODO: use a liveview inside a layout template?
      # create an empty visitor user and turn it into the full user once the user signes in/up

      # assert json = json_response(conn, 200)
      # assert %{is_colored: true} = Jason.decode!(json)
      # 
      # session = get_session(conn)
      # IO.inspect(session)
    end

    @tag :skip
    test "it's possible to update the settings" do
    end
  end

  @tag :skip
  test "settings from the session are copied into user during sing-up" do
  end

  @tag :skip
  describe "for authenticated user" do
    test "settings are taken from the user" do
      
    end

    test "it's possible to update the settings" do
      
    end
  end
end
