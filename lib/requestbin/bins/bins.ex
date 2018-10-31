defmodule Requestbin.Bins do
  @moduledoc """
  The Bins context.
  """

  import Ecto.Query, warn: false
  alias Requestbin.Repo

  alias Requestbin.Bins.{Bin, Request}

  ###
  # Bins

  @doc """
  Creates a bin.

  ## Examples

      iex> create_bin(%{name: value})
      {:ok, %Bin{name: value}}

  """
  @spec create_bin(%{String.t => any}) :: {:ok, Bin.t} | {:error, Ecto.Changeset.t}
  def create_bin(attrs \\ %{}) do
    %Bin{}
    |> Bin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single bin.

  Raises `Ecto.NoResultsError` if the Bin does not exist.

  ## Examples

      iex> get_bin!("123")
      %Bin{}

      iex> get_bin!("456")
      ** (Ecto.NoResultsError)

  """
  @spec get_bin!(String.t) :: Bin.t | none
  def get_bin!(id), do: Repo.get!(Bin, id)

  @doc """
  Deletes a Bin.

  ## Examples

      iex> delete_bin(bin)
      {:ok, %Bin{}}

      iex> delete_bin(bin)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_bin(Bin.t) :: {:ok, Bin.t} | {:error, Ecto.Changeset.t}
  def delete_bin(%Bin{} = bin) do
    Repo.delete(bin)
  end


  ###
  # Requests

  @doc """
  Creates a new request in the bin.

  ## Examples

      iex> create_request(%Plug.Conn{field: value})
      {:ok, %Request{}}

      iex> create_request(%Plug.Conn{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_request(Plug.Conn.t) :: {:ok, Request.t} | {:error, Ecto.Changeset.t}
  def create_request(conn) do
    %Request{}
    |> Request.changeset(conn)
    |> Repo.insert()
  end

  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  @spec list_requests(String.t) :: [Request.t] | none
  def list_requests(bin_id) when is_binary(bin_id) do
    # Repo.all(Request)
  end

  @doc """
  Gets a single request.

  Returns `nil` if the Request does not exist

  ## Examples

      iex> get_request("123", "abc")
      %Request{}

      iex> get_request("123", "def")
      nil
  """
  @spec get_request(String.t, String.t) :: Request.t | nil | none
  def get_request(bin_id, req_id), do: Repo.get_by(Request, bin_id: bin_id, id: req_id)

  @doc """
  Gets a single request.

  Raises `Ecto.NoResultsError` if the Request does not exist.

  ## Examples

      iex> get_request!("123", "abc")
      %Request{}

      iex> get_request!("123", "def")
      ** (Ecto.NoResultsError)

  """
  @spec get_request!(String.t, String.t) :: Request.t | none
  def get_request!(bin_id, req_id), do: Repo.get_by!(Request, bin_id: bin_id, id: req_id)

  @doc """
  Deletes a Request.

  ## Examples

      iex> delete_request(request)
      {:ok, %Request{}}

      iex> delete_request(request)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_request(Request.t) :: {:ok, Request.t} | {:error, Ecto.Changeset.t}
  def delete_request(%Request{} = request) do
    Repo.delete(request)
  end
end
