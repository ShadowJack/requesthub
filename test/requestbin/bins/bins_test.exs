defmodule Requestbin.BinsTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Bins
  alias Requestbin.Test.Factory

  describe "bins" do
    alias Requestbin.Bins.Bin

    @valid_attrs %{"name" => "Test bin"}

    test "get_bin/1 returns the bin with given id" do
      bin = Factory.insert(:bin)
      assert Bins.get_bin(bin.id) == bin
    end

    test "create_bin/1 with valid data creates a bin" do
      assert {:ok, %Bin{} = bin} = Bins.create_bin(@valid_attrs)
    end

    test "delete_bin/1 deletes the bin" do
      bin = Factory.insert(:bin)
      assert {:ok, %Bin{}} = Bins.delete_bin(bin)
      assert Bins.get_bin(bin.id) == nil
    end
  end

  describe "requests" do
    alias Requestbin.Bins.Request

    setup context do
      bin = Factory.insert(:bin)

      conn = 
        context.conn
        |> Map.put(:params, %{"bin_id" => bin.id})
        |> Map.put(:method, "GET")
        |> Map.put(:query_string, "?a=123&b=456")
        |> Map.put(:req_headers, [{"Content-Type", "application/json"}, {"Accept", "application/xml"}])
      [bin: bin, conn: conn]
    end

    def request_fixture(conn) do
      {:ok, request} = Bins.create_request(conn)

      request
    end

    # test "list_requests/0 returns all requests" do
    #   request = request_fixture()
    #   assert Bins.list_requests() == [request]
    # end

    test "get_request!/1 returns the request with given id", context do
      request = request_fixture(context[:conn])
      assert Bins.get_request!(context[:bin].id, request.id) == request
    end

    test "create_request/1 with valid data creates a request", context do

      assert {:ok, %Request{} = request} = Bins.create_request(context[:conn])
      assert request.verb == "GET"
      assert request.bin_id == context[:bin].id
      assert request.query == "?a=123&b=456"
      assert request.headers == %{"Content-Type" => "application/json", "Accept" => "application/xml"}
    end

    test "delete_request/1 deletes the request", context do
      request = request_fixture(context[:conn])
      assert {:ok, %Request{}} = Bins.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Bins.get_request!(context[:bin].id, request.id) end
    end
  end
end
