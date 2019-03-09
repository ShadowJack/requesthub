defmodule Requestbin.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @type user_id :: integer

  @primary_key {:id, :id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :binary

    many_to_many :bins, Requestbin.Bins.Bin, join_through: "users_bins"

    timestamps()
  end

  @doc """
  Empty changeset
  """
  def changeset(user) do
    change(user)
  end

  @doc """
  Prepare a user to be created
  """
  @spec changeset_for_signup(User.t, %{}) :: Changeset.t
  def changeset_for_signup(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name])
    |> hash_password(attrs)
    |> validate_required([:email, :password_hash])
  end

  @doc """
  Prepare a user to be updated
  """
  @spec changeset_for_update(User.t, %{}) :: Changeset.t
  def changeset_for_update(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
  end

  defp hash_password(changeset, attrs) do
    case Map.fetch(attrs, "password") do
      {:ok, pwd} -> 
        cast(changeset, Argon2.add_hash(pwd), [:password_hash])
      :error ->
        changeset
    end
  end
end
