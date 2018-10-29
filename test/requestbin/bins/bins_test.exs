defmodule Requestbin.BinsTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Bins

  describe "bins" do
    alias Requestbin.Bins.Bin

    @valid_attrs %{"name" => "Test bin"}

    def bin_fixture(attrs \\ %{}) do
      {:ok, bin} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bins.create_bin()

      bin
    end

    test "get_bin!/1 returns the bin with given id" do
      bin = bin_fixture()
      assert Bins.get_bin!(bin.id) == bin
    end

    test "create_bin/1 with valid data creates a bin" do
      assert {:ok, %Bin{} = bin} = Bins.create_bin(@valid_attrs)
    end

    test "delete_bin/1 deletes the bin" do
      bin = bin_fixture()
      assert {:ok, %Bin{}} = Bins.delete_bin(bin)
      assert_raise Ecto.NoResultsError, fn -> Bins.get_bin!(bin.id) end
    end
  end

  describe "requests" do
    alias Requestbin.Bins.Request

    setup context do
      bin = bin_fixture()

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
      assert Bins.get_request!(request.id) == request
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
      assert_raise Ecto.NoResultsError, fn -> Bins.get_request!(request.id) end
    end
  end
end
