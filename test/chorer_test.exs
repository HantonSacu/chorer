defmodule ChorerTest do
  use Chorer.DataCase, async: true

  import ChorerWeb.Support.TestHelpers

  alias Chorer.Repo
  alias Ecto.Adapters.SQL.Sandbox

  describe "accounts" do
    test "can befriend" do
      account_1 = register_account()
      account_2 = register_account()

      assert :ok == Chorer.befriend(account_1.id, account_2.id)
      assert [friend] = Chorer.account_friends(account_1.id)
      assert account_2.id == friend.id
      assert [friend] = Chorer.account_friends(account_2.id)
      assert account_1.id == friend.id
    end
  end

  describe "chores" do
    test "can be created" do
      account = register_account()
      chore = create_chore(account.id)

      assert [account_chore] = Chorer.account_chores(account.id)
      assert chore == account_chore
    end

    test "can be edited" do
      account = register_account()
      chore = create_chore(account.id)
      params = %{title: "New Title"}

      assert {:ok, _} = Chorer.edit_chore(chore.id, params)
      assert [account_chore] = Chorer.account_chores(account.id)
      refute chore.title == account_chore.title
      assert params.title == account_chore.title
    end

    test "can be deleted" do
      account = register_account()
      chore = create_chore(account.id)

      assert {:ok, _} = Chorer.delete_chore(chore.id)
      assert [] = Chorer.account_chores(account.id)
    end

    test "can be taken on and finished" do
      account = register_account()
      chore = create_chore(account.id)

      assert :available == chore.state
      assert {:ok, chore} = Chorer.take_on_chore(account.id, chore.id)
      assert :in_progress == chore.state
      assert {:ok, chore} = Chorer.finish_chore(account.id, chore.id)
      assert :done == chore.state
    end

    test "friends can see each other's chores" do
      account_1 = register_account()
      account_2 = register_account()
      chore = create_chore(account_1.id)

      assert [account_1_chore] = Chorer.account_chores(account_1.id)
      assert chore == account_1_chore
      assert [] = Chorer.account_chores(account_2.id)
      assert :ok = Chorer.befriend(account_1.id, account_2.id)

      assert [account_2_chore] = Chorer.account_chores(account_2.id)
      assert chore == account_2_chore
    end

    test "finished repeating daily becomes available" do
      account = register_account()
      chore = create_chore(account.id, frequency: 1)
      assert {:ok, chore} = Chorer.take_on_chore(account.id, chore.id)
      assert {:ok, _chore} = Chorer.finish_chore(account.id, chore.id)

      scheduler_pid = Process.whereis(Chorer.ChoresHandler)
      Sandbox.allow(Repo, self(), scheduler_pid)
      VBT.FixedJob.set_time(scheduler_pid, %{hour: 0, minute: 0})

      assert Periodic.Test.sync_tick(scheduler_pid) == {:ok, :normal}

      [chore] = Chorer.account_chores(account.id)
      assert chore.state == :available
    end

    test "finished repeating every two days does not become available" do
      account = register_account()
      chore = create_chore(account.id, frequency: 2)
      assert {:ok, chore} = Chorer.take_on_chore(account.id, chore.id)
      assert {:ok, _chore} = Chorer.finish_chore(account.id, chore.id)

      scheduler_pid = Process.whereis(Chorer.ChoresHandler)
      Sandbox.allow(Repo, self(), scheduler_pid)
      VBT.FixedJob.set_time(scheduler_pid, %{day: 0, hour: 0, minute: 0})

      assert Periodic.Test.sync_tick(scheduler_pid) == {:ok, :normal}

      [chore] = Chorer.account_chores(account.id)
      assert chore.state == :done
    end

    test "finished non repeating are deleted" do
      account = register_account()
      chore = create_chore(account.id, repeating?: false)
      assert {:ok, chore} = Chorer.take_on_chore(account.id, chore.id)
      assert {:ok, _chore} = Chorer.finish_chore(account.id, chore.id)

      scheduler_pid = Process.whereis(Chorer.ChoresHandler)
      Sandbox.allow(Repo, self(), scheduler_pid)
      VBT.FixedJob.set_time(scheduler_pid, %{day: 0, hour: 0, minute: 0})

      assert Periodic.Test.sync_tick(scheduler_pid) == {:ok, :normal}

      assert [] == Chorer.account_chores(account.id)
    end
  end
end
