defmodule ChorerConfig do
  use Provider,
    source: Provider.SystemEnv,
    params: [
      {:release_level, dev: "dev"},

      # database
      {:database_url, dev: dev_database_url()},
      {:database_pool_size, type: :integer, default: 10},
      {:database_ssl, type: :boolean, default: false},

      # email
      {:email_sender_address, dev: "sender@brevity.ninja"},
      {:email_support_address, dev: "support@brevity.ninja"},

      # endpoint
      {:host, dev: "localhost"},
      {:port, type: :integer, default: 4000, test: 4002},
      {:secret_key_base, dev: "secret_key_base"}
    ]

  if Mix.env() in ~w/dev test/a do
    defp dev_database_url do
      database_host = System.get_env("PGHOST", "localhost")
      database_name = if ci?(), do: "chorer_test", else: "chorer_#{unquote(Mix.env())}"
      "postgresql://postgres:postgres@#{database_host}/#{database_name}"
    end

    defp ci?, do: System.get_env("CI") == "true"
  end
end
