defmodule Requestbin.Repo.Migrations.AddParsedBodyField do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :parsed_body, :map
    end
  end
end
