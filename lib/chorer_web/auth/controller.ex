# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule ChorerWeb.Auth.Controller do
  use ChorerWeb, :controller

  alias ChorerWeb.Auth.{Login, Register}
  alias ChorerWeb.Authentication

  def login(conn, %{"login" => login}) do
    with {:ok, params} <- Login.normalize_login_params(login),
         {:ok, account} <- Chorer.authenticate_account(params.email, params.password) do
      Authentication.login_user(conn, account)
    else
      _error ->
        conn
        |> put_flash(:error, "Error logging in")
        |> redirect(to: Routes.account_path(conn, :login))
        |> halt()
    end
  end

  def register(conn, %{"register" => register_params}) do
    with {:ok, params} <- Register.normalize_register_params(register_params),
         {:ok, account} <- Chorer.sign_up(params),
         {:ok, account} <- Chorer.verify(account),
         {:ok, account} <- Chorer.authenticate_account(account.email, params.password) do
      Authentication.login_user(conn, account)
    else
      _error ->
        conn
        |> put_flash(:error, "Error registering")
        |> redirect(to: "/")
        |> halt()
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> Authentication.log_out_user()
  end
end
