defmodule Chorer.Repo do
  use VBT.Repo,
    otp_app: :chorer,
    adapter: Ecto.Adapters.Postgres
end
