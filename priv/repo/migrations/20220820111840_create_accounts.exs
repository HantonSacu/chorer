defmodule Chorer.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext;"

    create table(:accounts) do
      add :email, :citext, null: false
      add :password_hash, :text, null: false
      add :first_name, :text
      add :last_name, :text
      add :verified, :boolean

      timestamps()
    end

    create unique_index(:accounts, [:email])

    create table(:accounts_friends) do
      add :account_id, references(:accounts), null: false
      add :friend_id, references(:accounts), null: false
    end

    create unique_index(:accounts_friends, [:account_id, :friend_id])
  end

  def down do
    drop index(:accounts, [:email])
    drop table(:accounts_friends)
    drop table(:accounts)

    execute "DROP EXTENSION citext;"
  end
end
