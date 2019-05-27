defmodule Requestbin.Users.UserBin do
  @moduledoc """
  Association between users and bins
  """
  
  use Ecto.Schema

  schema "users_bins" do
    field :bin_id, Requestbin.PostgresTypes.UUID
    field :user_id, :integer
  end
end
