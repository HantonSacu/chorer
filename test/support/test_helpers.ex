defmodule ChorerWeb.Support.TestHelpers do
  alias VBT.TestHelper

  def register_account(params \\ []) do
    with {:ok, account} <-
           Chorer.sign_up(%{
             email: Keyword.get(params, :email, unique_email()),
             first_name: Keyword.get(params, :first_name, "John"),
             last_name: Keyword.get(params, :last_name, "Doe"),
             password: Keyword.get(params, :password, unique_password())
           }),
         {:ok, account} <- Chorer.verify(account),
         do: account
  end

  def create_chore(account_id, params \\ []) do
    with {:ok, chore} <-
           Chorer.create_chore(account_id, %{
             title: Keyword.get(params, :title, unique_title()),
             description: Keyword.get(params, :description, "desc"),
             state: Keyword.get(params, :state, :available),
             frequency: Keyword.get(params, :frequency, 1),
             repeating?: Keyword.get(params, :repeating?, true),
             duration: Keyword.get(params, :duration, 20),
             mental_difficulty: Keyword.get(params, :mental_difficulty, 3),
             physical_difficulty: Keyword.get(params, :physical_difficulty, 3)
           }),
         do: chore
  end

  defp unique_email, do: "t-#{TestHelper.unique_positive_integer()}@test.chorer"
  defp unique_title, do: "title#{TestHelper.unique_positive_integer()}"
  defp unique_password, do: "t-#{TestHelper.unique_positive_integer()}passWord!"
end
