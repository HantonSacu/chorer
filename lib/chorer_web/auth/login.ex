defmodule ChorerWeb.Auth.Login do
  use ChorerWeb, :live_view

  import Ecto.Changeset

  alias ChorerWeb.CommonComponents.{Flash, PasswordDarkInput, TextDarkInput}
  alias Surface.Components.Link

  @changeset change({%{}, %{email: :string, password: :string}})

  data changeset, :changeset, default: @changeset
  data trigger_submit, :boolean, default: false

  @type login_data :: %{email: String.t(), password: String.t()}

  @spec normalize_login_params(map(), boolean()) ::
          {:ok, login_data()} | {:error, Ecto.Changeset.t()}
  def normalize_login_params(login, required? \\ true) do
    string = if required?, do: {:string, required: true}, else: :string

    VBT.Validation.normalize(login, email: string, password: string)
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~F"""
    <div class="min-h-screen bg-gradient-to-br from-brevity-gray to-brevity-dark flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="flex justify-center space-x-4 h-10 text-3xl font-extrabold text-white">
          <img src={Routes.static_path(@socket, "/assets/images/icon.png")}>
          <h2>
            Login
          </h2>
        </div>
      </div>

      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="px-4 sm:rounded-lg sm:px-10">
          <form
            method="POST"
            :on-change="validate"
            :on-submit="submit"
            phx-trigger-action={@trigger_submit}
            id="login"
            class="space-y-6"
            autocomplete="off"
          >
            <input name="_csrf_token" type="hidden" value={Plug.CSRFProtection.get_csrf_token()}>

            <Flash type={:error} content={live_flash(@flash, :error)} />
            <Flash type={:info} content={live_flash(@flash, :info)} />

            <TextDarkInput form={form = to_form(@changeset, as: "login")} name={:email} />

            <PasswordDarkInput form={form} name={:password} />

            <div class="flex justify-center justify-between">
              <button
                type="submit"
                class="flex justify-center py-2 px-4 border border-1 border-white rounded-2xl shadow-sm text-sm font-light text-white bg-gray-600 hover:bg-brevity-light hover:text-brevity-dark focus:outline-none"
              >
                Login
              </button>
              <Link label="register" to="/register" class="self-center flex justify-center">
                <button
                  type="button"
                  class="py-2 px-4 border border-1 border-white rounded-2xl shadow-sm text-sm font-light text-white bg-gray-600 hover:bg-brevity-light hover:text-brevity-dark focus:outline-none"
                >
                  Register
                </button>
              </Link>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"login" => login}, socket) do
    socket = clear_flash(socket)

    case normalize_login_params(login, _required? = false) do
      {:ok, params} ->
        {:noreply, assign(socket, :changeset, change(socket.assigns.changeset, params))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("submit", %{"login" => login}, socket) do
    with {:ok, params} <- normalize_login_params(login),
         {:ok, _account} <- Chorer.authenticate_account(params.email, params.password) do
      {:noreply, socket |> clear_flash() |> assign(trigger_submit: true)}
    else
      {:error, changeset = %Ecto.Changeset{}} ->
        {:noreply, assign(socket, changeset: changeset, is_dirty: true)}

      {:error, error} ->
        {:noreply,
         socket
         |> clear_flash()
         |> put_flash(:error, error)}
    end
  end
end
