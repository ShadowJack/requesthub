defmodule Requestbin.Bins.Request do
  use Requestbin.Schema
  import Ecto.Changeset
  require Logger

  schema "requests" do
    belongs_to :bin, Requestbin.Bins.Bin

    field :verb, :string
    field :query, :string
    field :headers, :map
    field :body, :string
    field :ip_address, Requestbin.PostgresTypes.INET
    field :port, :integer

    timestamps()
  end

  @doc """
  A changeset for a new request
  """
  def changeset(request, %Plug.Conn{params: %{"bin_id" => bin_id}, method: verb, query_string: query, req_headers: headers} = conn) do
    peer_data = Plug.Conn.get_peer_data(conn)

    request
    |> change(
      bin_id: bin_id, 
      verb: verb, 
      body: read_body(conn),
      query: query,
      headers: cast_headers(headers),
      port: peer_data[:port])
    |> cast(%{"ip_address" => peer_data}, [:ip_address])
    |> validate_required([:bin_id, :verb])
    |> foreign_key_constraint(:bin_id)
  end

  @doc """
  Builds an error message from invalid changeset
  """
  def build_error_message(%Ecto.Changeset{errors: errors}) do
    Enum.reduce(errors, "An error has happened:\n", fn {field, {msg, _}}, acc -> 
      "#{acc}#{Atom.to_string(field)}:#{msg}\n"
    end)
  end


  @max_body_length_in_bytes 256_000
  def max_body_length_in_bytes() do
    @max_body_length_in_bytes
  end

  # Extract body either from conn.assigns or from the connection itself
  # If the max allowed length is exceeded, then body is truncated
  @spec read_body(Plug.Conn.t) :: String.t | nil
  defp read_body(conn) do
    case conn.assigns[:raw_body] do
      nil -> read_body_from_conn(conn)
      [] -> nil
      [body | _] -> body
    end
  end

  @spec read_body_from_conn(Plug.Conn.t) :: String.t
  defp read_body_from_conn(conn) do
    case Plug.Conn.read_body(conn, length: max_body_length_in_bytes()) do
      {:ok, body, _} -> body
      {:more, body, _} -> body
    end
  end

  @spec cast_headers([{String.t, String.t}]) :: %{ String.t => String.t | [String.t] } 
  defp cast_headers(headers) do
    headers
    |> Enum.reduce(%{}, fn ({key, val}, acc) -> 
      Map.update(acc, key, val, fn 
        curr_vals when is_list(curr_vals) -> [val | curr_vals] 
        curr_val -> [val, curr_val]
      end)
    end)
  end
end
