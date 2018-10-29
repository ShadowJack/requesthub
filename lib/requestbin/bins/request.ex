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

    timestamps()
  end

  @doc """
  A changeset for a new request
  """
  def changeset(request, %Plug.Conn{params: %{"bin_id" => bin_id}, method: verb, query_string: query, req_headers: headers} = conn) do
    body = read_body(conn)

    request
    |> change(
      bin_id: bin_id, 
      verb: verb, 
      body: body,
      query: query,
      headers: cast_headers(headers))
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

  defp read_body(conn) do
    case Plug.Conn.read_body(conn) do
      {:ok, data, _} -> data
      {:more, data, _} ->
        Logger.warn("Body is not fully read yet")
        data
      {:error, error} ->
        Logger.error("Error reading request body: #{error}")
        ""
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
