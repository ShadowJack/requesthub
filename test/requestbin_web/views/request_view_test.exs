defmodule RequestbinWeb.RequestViewTest do
  use RequestbinWeb.ConnCase, async: true
  alias Requestbin.Bins.{Request, RequestType}
  alias RequestbinWeb.RequestView
  
  import Phoenix.View

  defp build_request(type, body, query \\ nil, parsed_body \\ nil) do
    %Request{
      id: "test_id",
      bin_id: "test_bin_id", 
      verb: "POST",
      body: body,
      parsed_body: parsed_body,
      query: query,
      type: RequestType.get_type_id_by_name(type),
      port: 4000,
      ip_address: %Postgrex.INET{address: {127, 0, 0, 1}}
    }
  end

  describe "request details:" do

    test "sender info is presented", %{conn: conn} do
      req = build_request(:json, "")
      
      assert render_to_string(RequestView, "show.html", req: req, conn: conn) =~ "127.0.0.1:4000"
    end

    test "query string parsed and displayed", %{conn: conn} do
      req = build_request(:other, "", "q=test%20string&sort=+date&skip=10")

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ "Parsed query"
      assert rendered =~ ~r/<td>\s*q\s*<\/td>\s*<td>\s*test string\s*<\/td>/
    end

    test "arrays in query string are displayed correctly", %{conn: conn} do
      req = build_request(:other, "", "a[]=123&a[]=test%20message")

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ ~r/<td>\s*a\[\]\s*<\/td>\s*<td>\s*123\s*<\/td>/
      assert rendered =~ ~r/<td>\s*a\[\]\s*<\/td>\s*<td>\s*test message\s*<\/td>/
    end

    test "x-www-form-urlencoded body is displayed correctly", %{conn: conn} do
      req = build_request(:urlencoded, "a=123&b=456&c=test&d=false", nil, %{"a"=>"123", "b"=>"456", "c"=>"test", "d"=>"false"})

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ ~r/<td>\s*a\s*<\/td>\s*<td>\s*123\s*<\/td>/
    end

    test "parsed multipart/form-data is displayed correctly", %{conn: conn} do
      req = build_request(:multipart, "test", nil, %{"first_name"=>"john", "last_name"=>"doe"})

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ ~r/<td>\s*first_name\s*<\/td>\s*<td>\s*john\s*<\/td>/
      assert rendered =~ ~r/<td>\s*last_name\s*<\/td>\s*<td>\s*doe\s*<\/td>/
    end

    test "not parsed multipart/form-data is displayed correctly", %{conn: conn} do
      req = build_request(:multipart, "unparsed body", nil, %{})

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ "Wasn't able to parse"
      assert rendered =~ "unparsed body"
    end

    test "json is pretty-printed", %{conn: conn} do
      req = build_request(:json, "{\"a\": 123, \"b\": [\"a\", \"b\"]}", nil, %{})

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ """
      {\n  \"a\": 123,\n  \"b\": [\n    \"a\",\n    \"b\"\n  ]\n}
      """
    end
  end
end
