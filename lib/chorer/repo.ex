defmodule Chorer.Repo do
  use Ecto.Repo,
    otp_app: :chorer,
    adapter: Ecto.Adapters.Postgres
end
