defmodule RequestbinWeb.Controllers.RequestsTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Bins
  alias Requestbin.Bins.{Bin, Request}

  setup context do
    {:ok, bin} = Bins.create_bin(%{"name" => "Test bin"})
    
    [bin_id: bin.id]
  end

  test "can create a request with duplicated headers", context do
    conn = 
      context.conn
      |> put_req_header("x-header", "val1")
      |> put_req_header("x-header", "val2")
      |> post "/bins/#{context[:bin_id]}", %{"a" => "1"}

    assert get_flash(conn, :info) =~ "Request has been created"

    #TODO: get request and check its headers
  end

  test "can create application/json request", context do
    conn = 
      context.conn
      |> put_req_header("content-type", "application/json")
      |> post "/bins/#{context[:bin_id]}", "{\"a\": 123, \"arr\": [1,2,3]}"

    assert get_flash(conn, :info) =~ "Request has been created"

    #TODO: get request and check its body
  end

  test "can create application/x-www-form-urlencoded request", context do
    conn = 
      context.conn
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> post "/bins/#{context[:bin_id]}", "a=123&b=456&c=\"test\""

    assert get_flash(conn, :info) =~ "Request has been created"

    #TODO: get request and check its body
  end

  test "can create application/xml request", context do
    conn = 
      context.conn
      |> put_req_header("content-type", "application/xml")
      |> post "/bins/#{context[:bin_id]}", "<html><body><b style=\"color: black\">Test<b></body></html>"

    assert get_flash(conn, :info) =~ "Request has been created"

    #TODO: get request and check its body
  end

  test "can create GET request with query-string", context do
    conn = 
      context.conn
      |> get "/bins/#{context[:bin_id]}?abc=321&d=test"

    assert get_flash(conn, :info) =~ "Request has been created"

    #TODO: get request and check its body
  end
end
