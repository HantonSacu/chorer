defmodule ChorerSchemas.Score do
  use ChorerSchemas.Base

  alias ChorerSchemas.Account

  schema "scores" do
    field :points, :integer

    belongs_to :account, Account

    timestamps()
  end
end
