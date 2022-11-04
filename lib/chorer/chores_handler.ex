defmodule Chorer.ChoresHandler do
  import Ecto.Changeset

  alias Chorer.Repo

  def child_spec(_) do
    VBT.FixedJob.child_spec(
      id: __MODULE__,
      name: __MODULE__,
      run: &handle_chores/0,

      # configures desired time
      when: %{hour: 0, minute: 0},

      # prevents periodic job from running automatically in test mode
      mode: unquote(if Mix.env() == :test, do: :manual, else: :auto)
    )
  end

  defp handle_chores do
    Repo.transact(fn ->
      ChorerSchemas.Chore
      |> Repo.all()
      |> Enum.filter(&(&1.state == :done))
      |> Enum.each(&update_chore(&1))

      {:ok, :done}
    end)
  end

  defp update_chore(chore) do
    today = DateTime.utc_now()
    chore_datetime = DateTime.add(chore.updated_at, (chore.frequency - 1) * 3600 * 24, :second)

    cond do
      chore.repeating? and chore_datetime <= today ->
        Repo.update(change(chore, %{state: :available}))

      chore.repeating? ->
        {:ok, chore}

      true ->
        Repo.delete(chore)
    end
  end
end
