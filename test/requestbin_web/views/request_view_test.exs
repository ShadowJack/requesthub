defmodule RequestbinWeb.RequestViewTest do
  use RequestbinWeb.ConnCase, async: true
  alias Requestbin.Bins.Request
  alias RequestbinWeb.RequestView
  
  import Phoenix.View

  defp build_request(content_type, body, query \\ nil) do
    %Request{
      id: "test_id",
      bin_id: "test_bin_id", 
      verb: "POST",
      body: body,
      query: query,
      headers: %{"content-type" => content_type, "accept" => "text/html"},
      port: 4000,
      ip_address: %Postgrex.INET{address: {127, 0, 0, 1}}
    }
  end

  describe "request details:" do

    test "sender info is presented", %{conn: conn} do
      req = build_request("application/json", "")
      
      assert render_to_string(RequestView, "show.html", req: req, conn: conn) =~ "127.0.0.1:4000"
    end

    test "query string parsed and displayed", %{conn: conn} do
      req = build_request("application/json", "", "q=test%20string&sort=+date&skip=10")

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ "Parsed query"
      assert rendered =~ ~r/<td>\s*q\s*<\/td>\s*<td>\s*test string\s*<\/td>/
    end

    test "x-www-form-urlencoded body is parsed and displayed", %{conn: conn} do
      req = build_request("application/x-www-form-urlencoded", "a=123&b=456&c=\"test\"&d=false")

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ ~r/<td>\s*a\s*<\/td>\s*<td>\s*123\s*<\/td>/
    end

    @tag :skip
    test "multipart/form-data is parsed and displayed" do
      
    end


    @tag :skip
    test "json is pretty-printed" do
      
    end

  end
end
