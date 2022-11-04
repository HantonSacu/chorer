defmodule ChorerWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller

  alias ChorerSchemas.Account
  alias ChorerWeb.Router.Helpers, as: Routes
  alias VBT.Auth

  @user_salt "ChorerWeb user salt"
  @max_age :erlang.convert_time_unit(:timer.hours(24 * 30), :millisecond, :second)

  @spec encode_and_sign(Account.t()) :: String.t()
  def encode_and_sign(user),
    do: VBT.Auth.sign(ChorerWeb.Endpoint, @user_salt, %{id: user.id})

  @doc """
  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  @spec login_user(Plug.Conn.t(), Account.t()) :: Plug.Conn.t()
  def login_user(conn, user) do
    token = encode_and_sign(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  @doc """
  Logs the user out.
  Account
  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn, opts \\ []) do
    redirect_path = Keyword.get(opts, :redirect_to, signed_out_path(conn))

    if live_socket_id = get_session(conn, :live_socket_id) do
      ChorerWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> redirect(to: redirect_path)
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, opts \\ []) do
    redirect_path = Keyword.get(opts, :redirect_to, signed_in_path(conn))

    if get_session(conn, :user_token),
      do: conn |> redirect(to: redirect_path) |> halt(),
      else: conn
  end

  def require_user(conn, opts \\ []) do
    redirect_path = Keyword.get(opts, :redirect_to, signed_out_path(conn))

    with user_token when not is_nil(user_token) <-
           get_session(conn, :user_token),
         {:ok, user_data} <- verify_conn(conn, user_token),
         {:ok, user} <- load_account(user_data.id) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> renew_session()
        |> put_flash(:error, "You must log in to access this page.")
        |> redirect(to: redirect_path)
        |> halt()
    end
  end

  def check_live_session(socket, session) do
    with user_token when not is_nil(user_token) <- Map.get(session, "user_token"),
         {:ok, user_data} <- verify_socket(socket, user_token),
         {:ok, user} <- load_account(user_data.id) do
      Phoenix.LiveView.assign(socket, :current_user, user)
    else
      _ ->
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.push_redirect(to: "/")
    end
  end

  @spec new_token(Account.t()) :: String.t()
  def new_token(resource) do
    Auth.sign(ChorerWeb.Endpoint, @user_salt, %{id: resource.id})
  end

  @spec fetch_account(Auth.verifier(), Auth.args()) ::
          {:ok, Account.t()}
          | {:error, Auth.verify_error() | :account_not_found | :account_deleted}
  def fetch_account(verifier, args \\ []) do
    with {:ok, account_data} <- Auth.verify(verifier, @user_salt, @max_age, args),
         do: load_account(account_data.id)
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp verify_socket(socket, token),
    do: VBT.Auth.verify(socket, @user_salt, @max_age, %{"authorization" => "Bearer #{token}"})

  defp verify_conn(conn, token) do
    conn
    |> Plug.Conn.put_private(:phoenix_endpoint, ChorerWeb.Endpoint)
    |> VBT.Auth.verify(@user_salt, @max_age, %{"authorization" => "Bearer #{token}"})
  end

  defp signed_in_path(conn), do: Routes.account_path(conn, :home)

  defp signed_out_path(conn), do: Routes.account_path(conn, :login)

  defp load_account(id) do
    case Chorer.fetch_account(id) do
      {:error, _} ->
        {:error, :account_not_found}

      {:ok, account} ->
        {:ok, account}
    end
  end
end
