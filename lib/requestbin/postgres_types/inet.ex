defmodule Requestbin.PostgresTypes.INET do
  @behaviour Ecto.Type
  def type, do: Postgrex.INET

  # Casting from input into point struct
  def cast(value = %Postgrex.INET{}), do: {:ok, value}
  def cast(peer_data) when is_map(peer_data) do
    case peer_data[:address] do
      nil -> {:ok, nil}
      address -> {:ok, %Postgrex.INET{address: address}}
    end
  end

  def cast(_), do: :error

  # loading data from the database
  def load(data) do
    {:ok, data}
  end

  # dumping data to the database
  def dump(value = %Postgrex.INET{}), do: {:ok, value}
  def dump(_), do: :error
end
