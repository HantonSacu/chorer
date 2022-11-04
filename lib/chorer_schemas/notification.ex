defmodule ChorerSchemas.Notification do
  use ChorerSchemas.Base

  alias ChorerSchemas.{Account, Chore}

  schema "notifications" do
    field :info, :string
    field :link, :string

    belongs_to :account, Account
    belongs_to :chore, Chore

    timestamps()
  end
end
