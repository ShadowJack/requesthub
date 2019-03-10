defmodule Requestbin.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Requestbin.Repo

  alias Requestbin.Users.User
  alias Requestbin.Bins.Bin


  @doc """
  Gets a signle user.

  ## Examples

      iex> get_user(123)
      {:ok, %User{}}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Authenticate a user
  """
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)
    case Argon2.check_pass(user, password) do
      {:ok, _} -> {:ok, user}
      {:error, _} -> {:error, :invalid_credentials}
    end
  end

  @doc """
  Creates a new user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset_for_signup(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset_for_update(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user)
  end


  ##
  # Bins
  #

  @doc """
  Returns a list of bins for the user

  ## Examples

      iex> list_bins(%User{})
      [%Bin{}, ...]

  """
  @spec list_bins(User.t) :: [Bin.t] | none
  def list_bins(%User{} = user) do
    case Repo.preload(user, :bins) do
      nil -> []
      %User{bins: bins} -> bins
    end
  end
end
