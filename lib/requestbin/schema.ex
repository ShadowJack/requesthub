defmodule Requestbin.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, Requestbin.PostgresTypes.UUID, autogenerate: true}
      @foreign_key_type Requestbin.PostgresTypes.UUID
      @timestamps_opts [type: :utc_datetime, usec: true]
    end
  end
end
