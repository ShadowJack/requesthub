defmodule RequestbinWeb.RequestView do
  use RequestbinWeb, :view
  alias Requestbin.Bins.Request

  @doc """
  Build a short description of the request
  """
  @spec get_request_title(Request.t) :: String.t
  def get_request_title(%Request{} = req) do
    title = String.upcase(req.verb) <> " /" <> shorten_beginning(req.bin_id, 4) 

    if String.length(req.query) > 0 do
      title <> "?" <> req.query
    else
      title
    end
  end

  @doc """
  Representation of headers
  """
  @spec display_headers(%{String.t => any}) :: Phoenix.Html.safe
  def display_headers(headers) do
    raw(inspect(headers))
  end

  @doc """
  Representation of IP address and port
  """
  @spec display_who(Request.t) :: Phoenix.Html.safe
  def display_who(%Request{ip_address: nil, port: _}), do: raw(nil)
  def display_who(%Request{ip_address: %Postgrex.INET{address: addr}, port: port}) do
    address_string = 
      addr
      |> :inet_parse.ntoa()
      |> to_string()
    case port do
      nil -> raw(address_string)
      p -> raw(address_string <> ":" <> to_string(p))
    end
  end

  @doc """
  Parse a query string into a map
  """
  @spec parse_query_string(String.t) :: [{String.t, String.t}]
  def parse_query_string(query) do
    Plug.Conn.Query.decode(query)
  end

  @doc """
  Parse body and if successfully parsed, represent it as a table
  """
  @spec render_body(Request.t) :: Phoenix.Html.safe
  def render_body(%Request{body: nil}), do: nil
  def render_body(%Request{body: ""}), do: nil
  def render_body(%Request{body: body, headers: %{"content-type" => "application/x-www-form-urlencoded"}}) do
    parsed = Plug.Conn.Query.decode(body)
    ~E"""
      Parsed x-www-form-urlencoded body:<br/>
      <table>
        <thead>
          <tr>
            <th>Key</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <%= for {key, value} <- parsed do %>
            <tr>
              <td><%= key %></td>
              <td><%= value %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    """
  end
  def render_body(%Request{body: body, headers: %{"content-type" => "multipart/form-data"}}) do
      #TODO: parse form-data
  end
  def render_body(%Request{body: body, headers: %{"content-type" => "application/json"}}) do
      #TODO: pretty-print json
  end
  def render_body(%Request{body: body}) do
    # Content-type is not defined => return raw body
    render_raw_body(body)
  end

  @spec render_raw_body(String.t) :: Phoenix.Html.safe
  defp render_raw_body(body) do
    ~E"""
    <div>
      Raw body:
    </div>
    <div>
      <%= body %>
    </div>
    """
  end
end
