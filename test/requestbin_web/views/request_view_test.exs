defmodule RequestbinWeb.RequestViewTest do
  use RequestbinWeb.ConnCase, async: true
  alias Requestbin.Bins.{Request, RequestType}
  alias RequestbinWeb.RequestView
  alias Requestbin.Test.Factory
  
  import Phoenix.View

  describe "request details:" do

    test "sender info is presented", %{conn: conn} do
      req = Factory.build(:request, %{type: :json})
      
      assert render_to_string(RequestView, "show.html", req: req, conn: conn) =~ "127.0.0.1:4000"
    end

    test "query string parsed and displayed", %{conn: conn} do
      req = Factory.build(:request, %{type: :other, query: "q=test%20string&sort=+date&skip=10"})

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ "Query string params"
      assert rendered =~ ~r/<td>\s*q\s*<\/td>\s*<td>\s*test string\s*<\/td>/
    end

    test "arrays in query string are displayed correctly", %{conn: conn} do
      req = Factory.build(:request, %{type: :other, query: "a[]=123&a[]=test%20message"})

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ ~r/<td>\s*a\[\]\s*<\/td>\s*<td>\s*123\s*<\/td>/
      assert rendered =~ ~r/<td>\s*a\[\]\s*<\/td>\s*<td>\s*test message\s*<\/td>/
    end

    test "x-www-form-urlencoded body is displayed correctly", %{conn: conn} do
      req = Factory.build(:request, %{
        type: :urlencoded,
        query: "a=123&b=456&c=test&d=false",
        parsed_body: %{"a"=>"123", "b"=>"456", "c"=>"test", "d"=>"false"} 
      })

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ ~r/<td>\s*a\s*<\/td>\s*<td>\s*123\s*<\/td>/
    end

    test "parsed multipart/form-data is displayed correctly", %{conn: conn} do
      req = Factory.build(:request, %{
        type: :multipart,
        body: "test",
        parsed_body: %{"first_name"=>"john", "last_name"=>"doe"}
      })

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ ~r/<td>\s*first_name\s*<\/td>\s*<td>\s*john\s*<\/td>/
      assert rendered =~ ~r/<td>\s*last_name\s*<\/td>\s*<td>\s*doe\s*<\/td>/
    end

    test "not parsed multipart/form-data is displayed correctly", %{conn: conn} do
      req = Factory.build(:request, %{type: :multipart, body: "unparsed body", parsed_body: %{}})
      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ "Wasn't able to parse"
      assert rendered =~ "unparsed body"
    end

    test "json is pretty-printed", %{conn: conn} do
      req = Factory.build(:request, %{
        type: :json,
        body: "{\"a\": 123, \"b\": [\"a\", \"b\"]}",
        parsed_body: %{}
      })

      rendered = render_to_string(RequestView, "show.html", req: req, conn: conn)

      assert rendered =~ """
      {\n  \"a\": 123,\n  \"b\": [\n    \"a\",\n    \"b\"\n  ]\n}
      """
    end
  end
end
