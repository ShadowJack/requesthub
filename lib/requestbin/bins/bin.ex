defmodule Requestbin.Bins.Bin do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime, usec: true]
  schema "bins" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(bin, attrs \\ %{}) do
    bin
    |> cast(attrs, [:name])
  end
end
