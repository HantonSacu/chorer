defmodule ChorerConfig do
  use Provider,
    source: Provider.SystemEnv,
    params: [
      {:release_level, dev: "dev"},
      {:heroku_api_key, default: "fbaf23ad-6e54-4057-af41-6ca5d56fbb99"},

      # database
      {:database_url, default: dev_database_url()},
      {:database_pool_size, type: :integer, default: 10},
      {:database_ssl, type: :boolean, default: false},

      # email
      {:email_sender_address, dev: "sender@chorer.com"},
      {:email_support_address, dev: "support@chorer.com"},

      # endpoint
      {:host, dev: "localhost"},
      {:port, type: :integer, default: 5432, test: 5432},
      {:secret_key_base, dev: "secret_key_base"}
    ]

  #  if Mix.env() in ~w/dev test/a do
  defp dev_database_url do
    # database_host = System.get_env("PGHOST", "localhost")
    # database_name = if ci?(), do: "chorer_test", else: "chorer_#{unquote(Mix.env())}"

    "postgres://jxyuktkvyzpgrz:34f850d1646d61a9c937d77234ffc3b9139f125d48a4a2b9d28a8f5d9ca5ac75@ec2-54-228-218-84.eu-west-1.compute.amazonaws.com:5432/d83v2c6ol8c9eu"
  end

  #  defp ci?, do: System.get_env("CI") == "true"
  #  end
end
