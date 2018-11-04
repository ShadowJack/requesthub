defmodule Requestbin.Repo.Migrations.AddPortField do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :port, :integer
    end
  end
end
