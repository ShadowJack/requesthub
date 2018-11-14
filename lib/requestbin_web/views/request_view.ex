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
  @spec parse_body_and_display(Request.t) :: Phoenix.Html.safe
  def parse_body_and_display(%Request{body: nil}), do: nil
  def parse_body_and_display(%Request{body: body}) do
    #TODO: parse x-www-form-urlencoded
    #TODO: parse form-data
    #TODO: pretty-print json
    #TODO: pretty-print xml
  end

end
