defmodule Requestbin.Repo.Migrations.AddIpAddressField do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :ip_address, :inet
    end
  end
end
