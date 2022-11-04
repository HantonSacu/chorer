defmodule ChorerSchemas.Chore do
  use ChorerSchemas.Base

  alias ChorerSchemas.Account

  defenum State, :chore_state, ~w(available in_progress done)a

  schema "chores" do
    field :title, :string
    field :description, :string
    field :state, State, default: :available
    field :frequency, :integer
    field :repeating?, :boolean, default: false
    field :duration, :integer
    field :mental_difficulty, :integer
    field :physical_difficulty, :integer

    belongs_to :account, Account
    belongs_to :assignee, Account

    timestamps()
  end
end
