defmodule ChorerWeb.Account.ResetPassword do
  use ChorerWeb, :live_view

  import Ecto.Changeset

  alias ChorerWeb.CommonComponents.{Flash, PasswordDarkInput}

  @changeset change({%{}, %{password: :string, password_confirmation: :string}})

  data changeset, :changeset, default: @changeset
  data show_form, :boolean, default: true

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket),
    do: {:noreply, socket |> assign(%{route_params: params}) |> load_data()}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~F"""
    <div class="min-h-screen flex flex-col justify-center py-12 sm:px-6 lg:px-8 bg-gradient-to-br from-brevity-gray to-brevity-dark">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <img src={Routes.static_path(@socket, "/assets/images/logo.png")}>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-white">
        </h2>
      </div>

      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="mt-4 px-4 sm:rounded-lg sm:px-10">
          <Flash type={:error} content={live_flash(@flash, :error)} />
          <Flash type={:info} content={live_flash(@flash, :info)} />

          <form
            :on-change="validate"
            :on-submit="submit"
            :if={@show_form}
            id="reset_password"
            class="space-y-6"
          >
            <input name="_csrf_token" type="hidden" value={Plug.CSRFProtection.get_csrf_token()}>

            <PasswordDarkInput form={form = to_form(@changeset, as: "reset_password")} name={:password} />
            <PasswordDarkInput form={form} name={:password_confirmation} />

            <div class="flex justify-center">
              <button
                type="submit"
                class="flex justify-center py-2 px-4 border border-1 border-white rounded-2xl shadow-sm text-sm font-light text-white bg-gray-600 hover:bg-brevity-light hover:text-brevity-dark focus:outline-none"
              >
                Reset password
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"reset_password" => reset_password}, socket) do
    case normalize_reset_password_params(reset_password, _required? = false) do
      {:ok, params} -> {:noreply, assign(socket, :changeset, change(@changeset, params))}
      {:error, changeset} -> {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("submit", %{"reset_password" => reset_password}, socket) do
    with {:ok, params} <- normalize_reset_password_params(reset_password, true, _confirm? = true),
         token = socket.assigns.route_params["token"],
         {:ok, _account} <- Chorer.reset_password(token, params.password) do
      {:noreply,
       socket
       |> clear_flash()
       |> put_flash(:info, "Your password has been sucessfully reset.")
       |> assign(:show_form, false)
       |> assign(:changeset, @changeset)}
    else
      {:error, changeset = %Ecto.Changeset{}} ->
        {:noreply, assign(socket, changeset: changeset, is_dirty: true)}

      {:error, _} ->
        {:noreply, assign_invalid_token(socket)}
    end
  end

  defp load_data(%{assigns: %{route_params: params}} = socket) do
    if Chorer.password_reset_token_valid?(params["token"]),
      do: socket,
      else: assign_invalid_token(socket)
  end

  defp assign_invalid_token(socket) do
    socket
    |> clear_flash()
    |> put_flash(:error, "Reset password token is invalid or has expired.")
    |> assign(show_form: false, changeset: @changeset)
  end

  defp normalize_reset_password_params(reset_password, required?, confirm? \\ false) do
    string = if required?, do: {:string, required: true}, else: :string

    validations =
      if confirm?,
        do: &(&1 |> validate_password() |> confirm_password()),
        else: &validate_password/1

    VBT.Validation.normalize(reset_password, [password: string, password_confirmation: string],
      validate: validations
    )
  end

  defp validate_password(changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn :password, password ->
      if Chorer.validate_password(password),
        do: [],
        else: [
          password: "must contain at least one: uppercase letter, number and special character"
        ]
    end)
  end

  defp confirm_password(changeset),
    do: Ecto.Changeset.validate_confirmation(changeset, :password, required: true)
end
