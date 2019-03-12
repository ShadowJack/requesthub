defmodule Requestbin.Bins do
  @moduledoc """
  The Bins context.
  """

  import Ecto.Query, warn: false
  alias Requestbin.Repo

  alias Requestbin.Bins.{Bin, Request}
  alias Requestbin.Users.User

  ###
  # Bins

  @doc """
  Creates a bin.

  ## Examples

      iex> create_bin(%{name: value})
      {:ok, %Bin{name: value}}

  """
  @spec create_bin(%{String.t => any}, Reqeustbin.Users.User.t) :: {:ok, Bin.t} | {:error, Ecto.Changeset.t}
  def create_bin(attrs, user \\ nil) do
    %Bin{}
    |> Bin.changeset_for_insert(attrs, user)
    |> Repo.insert()
  end

  @doc """
  Gets a single bin.

  Returns `nil` if bin doesn't exist

  ## Examples

      iex> get_bin("123")
      %Bin{}

      iex> get_bin("456")
      nil

  """
  @spec get_bin(Bin.bin_id) :: Bin.t | nil
  def get_bin(id), do: Repo.get(Bin, id)

  @doc """
  Gets a single bin with preloaded requests.

  Returns `nil` if the bin doesn't exist

  ## Examples

      iex> get_bin("123")
      %Bin{requests: [%Request{}]}

      iex> get_bin("456")
      nil
  """
  @spec get_bin_with_requests(Bin.bin_id) :: Bin.t
  def get_bin_with_requests(bin_id) do
    get_bin(bin_id)
    |> Repo.preload(requests: (from r in Request, order_by: [desc: r.inserted_at]))
  end

  @doc """
  Gets several bins.

  ## Examples

      iex> get_bins(["123"])
      [%Bin{}]

      iex> get_bins(["456"])
      []

  """
  @spec get_bins([Bin.bin_id]) :: [Bin.t]
  def get_bins(ids) do
    Repo.all(from b in Bin, where: b.id in ^ids)
  end

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

  @doc """
  Check if access to the bin is allowed
  """
  @spec access_allowed?(Bin.bin_id, User.t) :: boolean
  def access_allowed?(bin_id, user) do
    user_ids = get_bin_owners(bin_id)

    cond do
      Enum.empty?(user_ids) -> 
        # public bin can be accessed by anyone
        true 
      user == nil -> 
        # unauthorized access
        false
      Enum.any?(user_ids, fn x -> x == user.id end) -> 
        # accessed by ownder
        true
      :otherwise -> 
        # accessed by user that is not an owner
        false
    end
  end

  @spec get_bin_owners(Bin.bin_id) :: [User.user_id]
  defp get_bin_owners(bin_id) do
    Repo.all(
      from b in Bin, 
      join: u in "users_bins", on: u.bin_id == b.id,
      where: b.id == ^bin_id,
      select: u.user_id
    )
  end
end
