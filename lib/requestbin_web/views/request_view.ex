defmodule RequestbinWeb.RequestView do
  use RequestbinWeb, :view
  alias Requestbin.Bins.{Request, RequestType}

  @doc """
  Build a request summary
  """
  @spec get_request_summary(Reqest.t) :: Phoenix.Html.safe
  def get_request_summary(%Request{verb: verb, type: type_id, body: body, query: query}) do
    verb_string = String.upcase(verb)

    type_string = case RequestType.get_type_name_by_id(type_id) do
      :other -> nil
      type -> to_string(type)
    end

    query_string = if String.length(query || "") > 0 do
      shorten(query, 50)
    else
      nil
    end

    body_string = if String.length(body || "") > 0 do
      shorten(body, 50)
    else
      nil
    end

    ~E"""
    <p><%= verb_string %></p>
    <%= if type_string do %>
      <p><%= type_string %></p>
    <%= end %>
    <%= if query_string do %>
      <p>query: <%= query_string %></p>
    <%= end %>
    <%= if body_string do %>
      <p>body: <%= body_string %></p>
    <%= end %>
    """
  end

  @doc """
  Render a key-value table
  """
  @spec render_key_value_table(%{String.t => String.t | [String.t]}) :: Phoenix.Html.safe
  def render_key_value_table(nil), do: nil
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
  def render_body(%Request{body: body, parsed_body: parsed_body, type: type_id}) do
    do_render_body(body, parsed_body, RequestType.get_type_name_by_id(type_id))
  end
  defp do_render_body(_, parsed_body, :urlencoded) do
    ~E"""
      Parsed x-www-form-urlencoded body:<br/>
      <%= render_key_value_table(parsed_body) %>
    """
  end
  defp do_render_body(body, parsed_body, :multipart) do
    if parsed_body == nil || parsed_body == %{} do
      ~E"""
      <div>Wasn't able to parse multipart/form-data</div>
      <%= render_raw_body(body) %>
      """
    else
      ~E"""
      <div>Parsed mulitpart/from-data body:</div>
      <div>
      <%= render_key_value_table(parsed_body) %>
      </div>
      """
    end
  end
  defp do_render_body(body, _, :json) do
    # pretty-print
      with {:ok, map} <- Jason.decode(body),
           {:ok, json} <- Jason.encode(map, pretty: true) do
        ~E"""
        Pretty-printed json body:
        <pre>
        <%= raw(json) %>
        </pre>
        <%= render_raw_body(body) %>
        """
      else
        {:error, %Jason.DecodeError{data: data, position: pos, token: token}} ->
          ~E"""
          <div>
          The json is invalid:
          <div>Data: <span><=% raw(data) %></span></div>
          <div>Position: <span><=% raw(pos) %></span></div>
          <div>Token: <span><=% raw(token) %></span></div>
          </div>
          <%= render_raw_body(body) %>
          """
      end
  end
  defp do_render_body(body, _, _) do
    render_raw_body(body)
  end

  @spec render_raw_body(String.t) :: Phoenix.Html.safe
  defp render_raw_body(body) do
    ~E"""
    <div>
      Raw body:
    </div>
    <pre>
      <%= body %>
    </pre>
    """
  end
end
