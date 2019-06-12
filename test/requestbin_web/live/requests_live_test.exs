defmodule RequestbinWeb.RequestsLiveTest do
  use Requestbin.DataCase

  import Phoenix.LiveViewTest

  alias RequestbinWeb.{Endpoint, RequestsLive}
  alias Requestbin.Test.Factory

  setup(ctx) do
    request = Factory.insert(:request)

    query = from b in Requestbin.Bins.Bin, 
      where: b.id == ^request.bin_id,
      preload: [:requests]
    bin = Requestbin.Repo.one(query)

    [bin: bin, req_id: request.id]
  end

  test "the list of requests is rendered", %{bin: bin, req_id: req_id} do
    {:ok, view, html} = mount(Endpoint, RequestsLive, session: %{bin: bin})

    assert html =~ "Latest requests"
    assert html =~ req_id
  end

  test "it's possible to delete request", %{bin: bin, req_id: req_id} do
    {:ok, view, _html} = mount(Endpoint, RequestsLive, session: %{bin: bin})
    
    html = render_click(view, :delete_request, req_id)

    assert (html =~ req_id) == false
    assert Requestbin.Repo.get(Requestbin.Bins.Request, req_id) == nil
  end

  test "request is removed from the view once it's deleted by other user", %{bin: bin, req_id: req_id} do
    {:ok, view, _html} = mount(Endpoint, RequestsLive, session: %{bin: bin})

    msg = %{
      event: RequestsLive.request_deleted_event(),
      payload: %{request_id: req_id}
    }
    send(view.pid, msg)

    assert (render(view) =~ req_id) == false
  end

  test "new request is displayed on the view", %{bin: bin, req_id: req_id} do
    {:ok, view, _html} = mount(Endpoint, RequestsLive, session: %{bin: bin})

    new_req = Factory.insert(:request, %{bin: bin})
    msg = %{
      event: RequestsLive.request_created_event(),
      payload: %{request: new_req}
    }
    send(view.pid, msg)

    assert render(view) =~ req_id
    assert render(view) =~ new_req.id
  end
end
