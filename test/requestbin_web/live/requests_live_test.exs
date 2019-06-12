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

  test "uncollapsed state is saved between events", %{bin: bin, req_id: req_id} do
    req2 = Factory.insert(:request, %{bin: bin})
    bin = 
      Requestbin.Bins.Bin
      |> Requestbin.Repo.get(bin.id)
      |> Requestbin.Repo.preload(:requests)
    {:ok, view, _html} = mount(Endpoint, RequestsLive, session: %{bin: bin})

    # uncollapse req2
    render_click(view, :toggle_collapse, req2.id)

    # insert a new request
    req3 = Factory.insert(:request, %{bin: bin})
    msg = %{
      event: RequestsLive.request_created_event(),
      payload: %{request: req3}
    }
    send(view.pid, msg)

    html = render(view)
    assert html =~ "#{req_id}\" role=\"button\" aria-expanded=\"true\""
    assert html =~ "#{req2.id}\" role=\"button\" aria-expanded=\"true\""
    assert html =~ "#{req3.id}\" role=\"button\" aria-expanded=\"false\""
  end
end
