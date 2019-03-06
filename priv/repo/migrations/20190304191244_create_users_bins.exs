defmodule Requestbin.Repo.Migrations.CreateUsersBins do
  use Ecto.Migration

  def change do
    create table(:users_bins) do
      add :user_id, references(:users, type: :id)
      add :bin_id, references(:bins, type: :binary_id)
    end

    create unique_index(:users_bins, [:user_id, :bin_id])
  end
end
