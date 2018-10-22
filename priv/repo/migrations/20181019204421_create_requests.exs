defmodule Requestbin.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bin_id, references("bins", on_delete: :delete_all, type: :binary_id), null: false

      add :verb, :string, size: 20
      add :query, :text
      add :headers, :map
      add :body, :text

      timestamps()
    end

  end
end
