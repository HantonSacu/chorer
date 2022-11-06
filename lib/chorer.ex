defmodule Chorer do
  import Ecto.Changeset
  import Ecto.Query

  alias Chorer.Repo
  alias ChorerSchemas.{Account, AccountFriend, Chore, Score, Token}
  alias VBT.Accounts

  @type sign_up_params :: %{
          :email => String.t(),
          :password => String.t(),
          :first_name => String.t(),
          :last_name => String.t()
        }

  @type register_params :: %{
          :email => String.t(),
          :password => String.t(),
          :first_name => String.t(),
          :last_name => String.t()
        }

  @type chore_params :: %{
          :title => String.t(),
          :description => String.t(),
          :state => Chore.State.t(),
          :frequency => integer(),
          :repeating? => boolean(),
          :duration => integer(),
          :mental_difficulty => integer(),
          :physical_difficulty => integer()
        }

end
