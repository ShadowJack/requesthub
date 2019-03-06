defmodule Requestbin.Bins.Bin do
  use Requestbin.Schema
  import Ecto.Changeset

  @type bin_id :: String.t

  schema "bins" do
    field :name, :string

    has_many :requests, Requestbin.Bins.Request
    many_to_many :users, Requestbin.Users.User, join_through: "users_bins"

    timestamps()
  end

  @doc """
  A changeset for a new bin
  """
  def changeset_for_insert(bin, attrs \\ %{}, user) do
    bin
    |> cast(attrs, [:name])
    |> assign_user(attrs, user)
  end

  defp assign_user(changeset, %{"private" => "true"}, nil) do
    add_error(changeset, :users, "unauthorized")
  end
  defp assign_user(changeset, %{"private" => "true"}, user) do
    put_assoc(changeset, :users, [user])
  end
  defp assign_user(changeset, _, _), do: changeset
end
