defmodule ChorerSchemas.Account do
  use ChorerSchemas.Base

  alias ChorerSchemas.{AccountFriend, Chore, Notification, Score}

  schema "accounts" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    field :verified, :boolean

    has_many :chores, Chore, where: [state: :in_progress]
    has_many :notifications, Notification
    has_many :accounts_friends, AccountFriend
    has_many :friends, through: [:accounts_friends, :friend]
    has_many :scores, Score

    timestamps()
  end
end
