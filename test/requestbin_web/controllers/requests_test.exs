defmodule RequestbinWeb.Controllers.RequestsTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Bins
  alias Requestbin.Bins.{Bin, Request}

  setup context do
    {:ok, bin} = Bins.create_bin(%{"name" => "Test bin"})
    
    [bin_id: bin.id]
  end

  @tag :skip
  # TODO: send a custom request with duplicated headers
  # because `put_req_header/3` overwrites the privious assignment
  test "can create a request with duplicated headers", %{conn: conn, bin_id: bin_id} do
    conn = 
      conn
      |> put_req_header("x-header", "val1")
      |> put_req_header("x-header", "val2")
      |> post "/bins/#{bin_id}", %{"a" => "1"}

    assert redirected_to(conn) =~ "/bins/"
    req = assert_and_get_request(conn, bin_id)
    assert req.headers == %{"x-header" => ["val1", "val2"]}
  end

  test "can create application/json request", %{bin_id: bin_id, conn: conn} do
    conn = 
      conn
      |> put_req_header("content-type", "application/json")
      |> post "/bins/#{bin_id}", "{\"a\": 123, \"arr\": [1,2,3]}"

    req = assert_and_get_request(conn, bin_id)
    assert %{"content-type" => "application/json"} = req.headers
    assert req.body == "{\"a\": 123, \"arr\": [1,2,3]}"
  end

  test "can create application/x-www-form-urlencoded request", %{bin_id: bin_id, conn: conn} do
    conn = 
      conn
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> post "/bins/#{bin_id}", "a=123&b=456&c=\"test\""

    req = assert_and_get_request(conn, bin_id)
    assert %{"content-type" => "application/x-www-form-urlencoded"} = req.headers
    assert req.body == "a=123&b=456&c=\"test\""
  end

  test "can create multipart/formdata request", %{bin_id: bin_id, conn: conn} do
    conn = 
      conn
      |> put_req_header("content-type", "multipart/formdata; boundary=--requests_test--")
      |> post("/bins/#{bin_id}", 
        """
        --requests_test--
        Content-Disposition: form-data; name="text1"

        text default
        --requests_test--
        """)

    req = assert_and_get_request(conn, bin_id)
    assert %{"content-type" => "multipart/formdata; boundary=--requests_test--"} = req.headers
    assert req.body =~ "name=\"text1\""
  end

  test "can create application/xml request", %{bin_id: bin_id, conn: conn} do
    conn = 
      conn
      |> put_req_header("content-type", "application/xml")
      |> post "/bins/#{bin_id}", "<html><body><b style=\"color: black\">Test</b></body></html>"

    req = assert_and_get_request(conn, bin_id)
    assert %{"content-type" => "application/xml"} = req.headers
    assert req.body =~ "Test</b>"
  end

  test "can create a GET request with query-string", %{bin_id: bin_id, conn: conn} do
    conn = 
      conn
      |> get "/bins/#{bin_id}?abc=321&d=test"

    req = assert_and_get_request(conn, bin_id)
    assert "GET" == req.verb
    assert "abc=321&d=test" == req.query
  end

  test "can create a PATCH request", %{bin_id: bin_id, conn: conn} do
    conn = 
      conn
      |> put_req_header("content-type", "application/json")
      |> patch "/bins/#{bin_id}?abc=321&d=test", "{\"a\": 1}"

    req = assert_and_get_request(conn, bin_id)
    assert "PATCH" == req.verb
  end

  test "cookies are saved in headers", %{bin_id: bin_id, conn: conn} do
    conn = 
      conn
      |> put_req_cookie("TestCookie", "Test cookie value")
      |> get "/bins/#{bin_id}?abc=321&d=test"

    req = assert_and_get_request(conn, bin_id)
    assert %{ "cookie" => "TestCookie=Test cookie value" } = req.headers
  end

  @spec assert_and_get_request(Plug.Conn.t, String.t) :: Request.t | none
  defp assert_and_get_request(conn, bin_id) do
    assert get_flash(conn, :info) =~ "Request has been created"
    assert %{bin_id: ^bin_id, req_id: req_id} = redirected_params(conn)
    Bins.get_request!(bin_id, req_id)
  end
end
