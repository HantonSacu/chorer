defmodule Chorer.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :points, :integer, null: false
      add :account_id, references(:accounts), null: false

      timestamps()
    end
  end
end
