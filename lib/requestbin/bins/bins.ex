defmodule Requestbin.Bins do
  @moduledoc """
  The Bins context.
  """

  import Ecto.Query, warn: false
  alias Requestbin.Repo

  alias Requestbin.Bins.Bin

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
end
