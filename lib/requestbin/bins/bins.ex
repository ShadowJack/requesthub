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
  def create_bin(attrs \\ %{}) do
    %Bin{}
    |> Bin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Deletes a Bin.

  ## Examples

      iex> delete_bin(bin)
      {:ok, %Bin{}}

      iex> delete_bin(bin)
      {:error, %Ecto.Changeset{}}

  """
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
  def list_requests do
    Repo.all(Request)
  end

  @doc """
  Gets a single request.

  Raises `Ecto.NoResultsError` if the Request does not exist.

  ## Examples

      iex> get_request!(123)
      %Request{}

      iex> get_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_request!(id), do: Repo.get!(Request, id)


  @doc """
  Deletes a Request.

  ## Examples

      iex> delete_request(request)
      {:ok, %Request{}}

      iex> delete_request(request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_request(%Request{} = request) do
    Repo.delete(request)
  end
end
