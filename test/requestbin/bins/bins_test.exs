defmodule Requestbin.BinsTest do
  use Requestbin.DataCase

  alias Requestbin.Bins

  describe "bins" do
    alias Requestbin.Bins.Bin

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def bin_fixture(attrs \\ %{}) do
      {:ok, bin} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bins.create_bin()

      bin
    end

    test "list_bins/0 returns all bins" do
      bin = bin_fixture()
      assert Bins.list_bins() == [bin]
    end

    test "get_bin!/1 returns the bin with given id" do
      bin = bin_fixture()
      assert Bins.get_bin!(bin.id) == bin
    end

    test "create_bin/1 with valid data creates a bin" do
      assert {:ok, %Bin{} = bin} = Bins.create_bin(@valid_attrs)
    end

    test "create_bin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bins.create_bin(@invalid_attrs)
    end

    test "update_bin/2 with valid data updates the bin" do
      bin = bin_fixture()
      assert {:ok, bin} = Bins.update_bin(bin, @update_attrs)
      assert %Bin{} = bin
    end

    test "update_bin/2 with invalid data returns error changeset" do
      bin = bin_fixture()
      assert {:error, %Ecto.Changeset{}} = Bins.update_bin(bin, @invalid_attrs)
      assert bin == Bins.get_bin!(bin.id)
    end

    test "delete_bin/1 deletes the bin" do
      bin = bin_fixture()
      assert {:ok, %Bin{}} = Bins.delete_bin(bin)
      assert_raise Ecto.NoResultsError, fn -> Bins.get_bin!(bin.id) end
    end

    test "change_bin/1 returns a bin changeset" do
      bin = bin_fixture()
      assert %Ecto.Changeset{} = Bins.change_bin(bin)
    end
  end

  describe "requests" do
    alias Requestbin.Bins.Request

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def request_fixture(attrs \\ %{}) do
      {:ok, request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bins.create_request()

      request
    end

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Bins.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Bins.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      assert {:ok, %Request{} = request} = Bins.create_request(@valid_attrs)
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bins.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      assert {:ok, request} = Bins.update_request(request, @update_attrs)
      assert %Request{} = request
    end

    test "update_request/2 with invalid data returns error changeset" do
      request = request_fixture()
      assert {:error, %Ecto.Changeset{}} = Bins.update_request(request, @invalid_attrs)
      assert request == Bins.get_request!(request.id)
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Bins.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Bins.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Bins.change_request(request)
    end
  end
end
