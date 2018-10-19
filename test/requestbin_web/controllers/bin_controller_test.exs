defmodule RequestbinWeb.BinControllerTest do
  use RequestbinWeb.ConnCase

  alias Requestbin.Bins

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:bin) do
    {:ok, bin} = Bins.create_bin(@create_attrs)
    bin
  end

  describe "index" do
    test "lists all bins", %{conn: conn} do
      conn = get conn, bin_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Bins"
    end
  end

  describe "new bin" do
    test "renders form", %{conn: conn} do
      conn = get conn, bin_path(conn, :new)
      assert html_response(conn, 200) =~ "New Bin"
    end
  end

  describe "create bin" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, bin_path(conn, :create), bin: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == bin_path(conn, :show, id)

      conn = get conn, bin_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Bin"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, bin_path(conn, :create), bin: @invalid_attrs
      assert html_response(conn, 200) =~ "New Bin"
    end
  end

  describe "edit bin" do
    setup [:create_bin]

    test "renders form for editing chosen bin", %{conn: conn, bin: bin} do
      conn = get conn, bin_path(conn, :edit, bin)
      assert html_response(conn, 200) =~ "Edit Bin"
    end
  end

  describe "update bin" do
    setup [:create_bin]

    test "redirects when data is valid", %{conn: conn, bin: bin} do
      conn = put conn, bin_path(conn, :update, bin), bin: @update_attrs
      assert redirected_to(conn) == bin_path(conn, :show, bin)

      conn = get conn, bin_path(conn, :show, bin)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, bin: bin} do
      conn = put conn, bin_path(conn, :update, bin), bin: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Bin"
    end
  end

  describe "delete bin" do
    setup [:create_bin]

    test "deletes chosen bin", %{conn: conn, bin: bin} do
      conn = delete conn, bin_path(conn, :delete, bin)
      assert redirected_to(conn) == bin_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, bin_path(conn, :show, bin)
      end
    end
  end

  defp create_bin(_) do
    bin = fixture(:bin)
    {:ok, bin: bin}
  end
end
