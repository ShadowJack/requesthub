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
  Render a key-value table
  """
  @spec render_key_value_table(%{String.t => String.t | [String.t]}) :: Phoenix.Html.safe
  def render_key_value_table(map) when map == %{}, do: nil
  def render_key_value_table(map) do
    # get rid of internal lists
    list = map |> Map.to_list() |> flatten_key_value_list()
    ~E"""
      <table>
        <thead>
          <tr>
            <th>Key</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <%= for {key, value} <- list do %>
            <tr>
              <td><%= key %></td>
              <td><%= value %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    """
  end

  defp flatten_key_value_list(list) do
    do_flatten_key_value_list(list, [])
  end

  defp do_flatten_key_value_list([], acc), do: Enum.reverse(acc)
  defp do_flatten_key_value_list([{k, list_value} | tail], acc) when is_list(list_value) do
    flattened = 
      list_value 
      |> Enum.map(fn v -> {"#{k}[]", v} end) 
      |> Enum.reverse()
    do_flatten_key_value_list(tail, flattened ++ acc)
  end
  defp do_flatten_key_value_list([head | tail], acc) do
    do_flatten_key_value_list(tail, [head | acc])
  end


  ## Render parts of the request
  #

  @doc """
  Representation of headers
  """
  @spec render_headers(%{String.t => any}) :: Phoenix.Html.safe
  def render_headers(headers) do
    raw(inspect(headers))
  end

  @doc """
  Representation of IP address and port
  """
  @spec render_who(Request.t) :: Phoenix.Html.safe
  def render_who(%Request{ip_address: nil, port: _}), do: raw(nil)
  def render_who(%Request{ip_address: %Postgrex.INET{address: addr}, port: port}) do
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
  Representation of a query string
  """
  @spec render_query_string(Request.t) :: Phoenix.Html.safe
  def render_query_string(%Request{query: nil}), do: nil
  def render_query_string(%Request{query: ""}), do: nil
  def render_query_string(%Request{query: query}) do
    parsed = Plug.Conn.Query.decode(query)

    ~E"""
    Parsed query string:<br/>
    <%= render_key_value_table(parsed) %>
    """
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
      <%= render_key_value_table(parsed) %>
    """
  end
  def render_body(%Request{body: body, headers: %{"content-type" => "multipart/form-data"}}) do
    #TODO: parse form-data
  end
  def render_body(%Request{body: body, headers: %{"content-type" => "application/json"}}) do
    #TODO: pretty-print json
    render_raw_body(body)
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
