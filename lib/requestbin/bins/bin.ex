defmodule Requestbin.Bins.Bin do
  use Requestbin.Schema
  import Ecto.Changeset

  @type bin_id :: String.t

  schema "bins" do
    field :name, :string

    has_many :requests, Requestbin.Bins.Request

    timestamps()
  end

  @doc false
  def changeset(bin, attrs \\ %{}) do
    bin
    |> cast(attrs, [:name])
  end
end
