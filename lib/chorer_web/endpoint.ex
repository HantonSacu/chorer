defmodule ChorerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chorer
  use Absinthe.Phoenix.Endpoint

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_chorer_key",
    signing_salt: "4iq4u1eX"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :chorer,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :chorer
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ChorerWeb.Router

  # @impl Phoenix.Endpoint
  # def init(_type, config) do
  #   config =
  #     config
  #     |> Keyword.put(:secret_key_base, ChorerConfig.secret_key_base())
  #     |> Keyword.update(:url, url_config(), &Keyword.merge(&1, url_config()))
  #     |> Keyword.update(:http, http_config(), &(http_config() ++ (&1 || [])))

  #   {:ok, config}
  # end

  # defp url_config, do: [host: ChorerConfig.host()]
  # defp http_config, do: [:inet6, port: ChorerConfig.port()]
end
