defmodule RequestbinWeb.RequestsLiveTest do
  use RequestbinWeb.ChannelCase

  import Phoenix.LiveViewTest

  alias RequestbinWeb.{Endpoint, RequestsLive}
  alias Requestbin.Test.Factory

  setup(ctx) do
    bin = Factory.insert(:bin)

    [bin: bin]
  end

  test "the list of requests is rendered", %{bin: bin} do
    {:ok, view, html} = mount(Endpoint, RequestsLive, session: %{bin: bin})

    assert html =~ "Latest requests"
  end

  test "deleted request is removed from the view" do
    
  end

  test "new request is displayed on the view" do
    
  end
end
