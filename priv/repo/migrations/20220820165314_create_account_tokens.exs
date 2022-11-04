defmodule Chorer.Repo.Migrations.CreateAccountTokens do
  use Ecto.Migration

  def change do
    create table(:tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :hash, :binary, null: false
      add :type, :string, null: false
      add :used_at, :utc_datetime
      add :expires_at, :utc_datetime, null: false
      add :account_id, references(:accounts, type: :uuid), null: true

      timestamps()
    end
  end
end
