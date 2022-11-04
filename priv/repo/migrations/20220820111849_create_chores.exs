defmodule Chorer.Repo.Migrations.CreateChores do
  use Ecto.Migration

  import EctoEnum

  defenum State, :chore_state, ~w(available in_progress done)a

  def change do
    State.create_type()

    create table(:chores) do
      add :title, :text, null: false
      add :description, :text, null: false
      add :state, State.type(), null: false, default: "available"
      add :frequency, :integer, null: false
      add :repeating?, :boolean, default: false
      add :duration, :integer, null: false
      add :mental_difficulty, :integer, null: false
      add :physical_difficulty, :integer, null: false
      add :account_id, references(:accounts)
      add :assignee_id, references(:accounts)

      timestamps()
    end

    create unique_index(:chores, [:title])
  end
end
