[
  import_deps: [:absinthe, :ecto, :ecto_enum, :ecto_sql, :phoenix, :surface],
  inputs: [
    "lib/**/*.{ex,sface}",
    "priv/*/seeds.exs",
    "priv/*/migrations/*.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  plugins: [Surface.Formatter.Plugin]
]
