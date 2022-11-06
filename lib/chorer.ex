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

  ######################
  # ACCOUNT MANAGEMENT #
  ######################

  @spec sign_up(sign_up_params()) ::
          {:ok, Account.t()} | {:error, String.t()}
  def sign_up(params) do
    Repo.transact(fn ->
      with :ok <- VBT.validate(validate_password(params.password), "Invalid password format"),
           {:ok, account} <- create_account(params) do
        {:ok, account}
      else
        {:error, _error} ->
          {:error, "Sign up failed."}
      end
    end)
  end

  # {:ok, _job} <- send_activation_email(account) do

  @spec verify(Account.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def verify(account), do: account |> change(%{verified: true}) |> Repo.update()

  @spec reset_password(String.t(), String.t()) ::
          {:ok, Account.t()} | {:error, :invalid | Ecto.Changeset.t()}
  def reset_password(token, new_password) do
    case Accounts.reset_password(token, new_password, accounts_config()) do
      {:ok, account} -> {:ok, account}
      {:error, :invalid} -> {:error, "Password reset token expired"}
      {:error, _} = error -> error
    end
  end

  @spec change_password(Account.t(), String.t(), String.t()) ::
          {:ok, Account.t()} | {:error, :invalid | String.t() | Ecto.Changeset.t()}
  def change_password(account, old_password, new_password) do
    with :ok <- VBT.validate(validate_password(new_password), "Invalid new password format"),
         {:ok, account} <-
           Accounts.change_password(account, old_password, new_password, accounts_config()) do
      {:ok, account}
    else
      {:error, :invalid} -> {:error, "Incorrect old password"}
      {:error, _} = error -> error
    end
  end

  @spec edit_account(Account.t(), register_params()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def edit_account(account, params) do
    params = Map.new(Enum.filter(params, fn {_key, value} -> not is_nil(value) end))
    account |> change(params) |> Repo.update()
  end

  @spec validate_password(String.t()) :: boolean()
  def validate_password(password) do
    String.contains?(password, String.graphemes("ABCDEFGHIJKLMNOPQRSTUVWXYZ")) and
      String.contains?(password, String.graphemes("0123456789"))
  end

  @spec password_reset_token_valid?(String.t()) :: boolean()
  def password_reset_token_valid?(token),
    do: not is_nil(Accounts.Token.get_account(token, "password_reset", accounts_config()))

  @spec get_account_by_password_reset_token(String.t()) :: Account.t() | nil
  def get_account_by_password_reset_token(token),
    do: VBT.Accounts.Token.get_account(token, "password_reset", accounts_config())

  @spec activate_account(String.t()) ::
          {:ok, Account.t()} | {:error, String.t()}
  def activate_account(token) do
    case Accounts.Token.use(token, "user_activation", &activate(&1), accounts_config()) do
      {:error, :invalid} -> {:error, "Activation token expired"}
      {:error, _} = error -> error
      {:ok, account} -> {:ok, account}
    end
  end

  @spec authenticate_account(String.t(), String.t()) ::
          {:ok, Account.t()} | {:error, :invalid}
  def authenticate_account(email, password) do
    Accounts.authenticate(email, password, accounts_config())
  end

  @spec create_account(register_params()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def create_account(params) do
    %Account{}
    |> change(Map.drop(params, [:email, :password]))
    |> validate_required([:first_name, :last_name])
    |> VBT.Accounts.create(params.email, params.password, accounts_config())
  end

  @spec fetch_account(String.t()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def fetch_account(id) do
    Repo.fetch_one(from(Account, where: [id: ^id], preload: [:friends]))
  end

  @spec accounts() :: [Account.t()]
  def accounts, do: Chorer.Repo.all(Account)

  @spec account_friends(String.t()) :: [Account.t()]
  def account_friends(account_id) do
    with {:ok, account} <- fetch_account(account_id), do: account.friends
  end

  @spec account_points(String.t()) :: integer() | nil
  def account_points(account_id) do
    Repo.one(from(s in Score, where: s.account_id == ^account_id, select: sum(s.points)))
  end

  @spec befriend(String.t(), String.t()) :: :ok | {:error, Ecto.Changeset.t()}
  def befriend(account_id, friend_id) do
    with {:ok, _friend_1} <-
           Repo.insert(%AccountFriend{account_id: account_id, friend_id: friend_id}),
         {:ok, _friend_2} <-
           Repo.insert(%AccountFriend{account_id: friend_id, friend_id: account_id}) do
      :ok
    end
  end

  @spec unfriend(String.t(), String.t()) :: :ok | {:error, String.t() | Ecto.Changeset.t()}
  def unfriend(account_id, friend_id) do
    with {:ok, friend_1} <-
           Repo.fetch_by(AccountFriend, %{account_id: account_id, friend_id: friend_id}),
         {:ok, _friend_1} <- Repo.delete(friend_1),
         {:ok, friend_2} <-
           Repo.fetch_by(AccountFriend, %{account_id: friend_id, friend_id: account_id}),
         {:ok, _friend_2} <- Repo.delete(friend_2) do
      :ok
    end
  end

end
