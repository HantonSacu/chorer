defmodule Chorer.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :info, :text, null: false
      add :link, :text, null: false
      add :account_id, references(:accounts), null: false
      add :chore_id, references(:chores)

      timestamps()
    end
  end
end
