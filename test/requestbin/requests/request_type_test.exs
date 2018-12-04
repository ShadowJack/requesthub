defmodule RequestTypeTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Bins.RequestType
  
  test "urlencoded is detected", %{conn: conn} do
    type = 
      conn
      |> put_req_header("content-type", "application/x-www-form-urlencoded; charset utf-8")
      |> RequestType.detect_type()
      |> RequestType.get_type_name_by_id()

    assert type == :urlencoded
  end

  test "multipart is detected", %{conn: conn} do
    type = 
      conn
      |> put_req_header("content-type", "multipart/form-data; charset utf-8")
      |> RequestType.detect_type()
      |> RequestType.get_type_name_by_id()

    assert type == :multipart
  end

  test "json is detected", %{conn: conn} do
    type = 
      conn
      |> put_req_header("content-type", "application/json")
      |> RequestType.detect_type()
      |> RequestType.get_type_name_by_id()

    assert type == :json
  end

  test "xml is detected", %{conn: conn} do
    type = 
      conn
      |> put_req_header("content-type", "application/xml")
      |> RequestType.detect_type()
      |> RequestType.get_type_name_by_id()

    assert type == :xml
  end

  test ":other is used for unrecognized types", %{conn: conn} do
    type = 
      conn
      |> RequestType.detect_type()
      |> RequestType.get_type_name_by_id()

    assert type == :other
  end
end
