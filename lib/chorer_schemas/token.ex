defmodule ChorerSchemas.Token do
  use ChorerSchemas.Base

  alias ChorerSchemas.Account

  schema "tokens" do
    field :hash, :binary
    field :type, :string
    field :used_at, :utc_datetime
    field :expires_at, :utc_datetime

    belongs_to :account, Account

    timestamps()
  end
end
