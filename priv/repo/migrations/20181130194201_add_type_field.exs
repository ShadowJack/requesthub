defmodule Requestbin.Repo.Migrations.AddTypeField do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :type, :integer
    end
  end
end
