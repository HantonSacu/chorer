defmodule ChorerSchemas.AccountFriend do
  use ChorerSchemas.Base

  alias ChorerSchemas.Account

  schema "accounts_friends" do
    belongs_to :account, Account
    belongs_to :friend, Account
  end
end
