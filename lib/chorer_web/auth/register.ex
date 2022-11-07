defmodule ChorerWeb.Auth.Register do
  use ChorerWeb, :live_view

  import Ecto.Changeset

  alias ChorerWeb.CommonComponents.{EmailInput, Flash, PasswordInput, TextInput}

  @changeset change(
               {%{},
                %{email: :string, first_name: :string, last_name: :string, password: :string}}
             )

  data changeset, :changeset, default: @changeset
  data trigger_submit, :boolean, default: false

  @type login_data :: %{email: String.t(), password: String.t()}

  @spec normalize_register_params(map(), boolean()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def normalize_register_params(params, required? \\ true) do
    string = if required?, do: {:string, required: true}, else: :string

    VBT.Validation.normalize(params,
      email: string,
      first_name: string,
      last_name: string,
      password: string
    )
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket),
    do: {:noreply, socket |> assign(%{route_params: params}) |> load_data(params)}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~F"""
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 class="flex justify-center space-x-4 h-10 text-3xl font-extrabold text-gray-900">
          <img src={Routes.static_path(@socket, "/assets/images/icon.png")}>
          <div>Registration</div>
        </h2>
      </div>

      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <form
            method="POST"
            :on-change="validate"
            :on-submit="submit"
            phx-trigger-action={@trigger_submit}
            id="register"
            class="space-y-6"
          >
            <input name="_csrf_token" type="hidden" value={Plug.CSRFProtection.get_csrf_token()}>

            <Flash type={:error} content={live_flash(@flash, :error)} />
            <Flash type={:info} content={live_flash(@flash, :info)} />

            <EmailInput form={form = to_form(@changeset, as: "register")} name={:email} />

            <TextInput form={form} name={:first_name} />

            <TextInput form={form} name={:last_name} />

            <PasswordInput form={form} name={:password} placeholder="••••••••" />

            <div>
              <button
                disabled={not @changeset.valid? or @changeset.changes == %{}}
                type="submit"
                class={"#{disable(@changeset)} w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"}
              >
                Sign up
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"register" => register}, socket) do
    case normalize_register_params(register, _required? = false) do
      {:ok, params} ->
        {:noreply, assign(socket, :changeset, change(@changeset, params))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("submit", %{"register" => register}, socket) do
    case normalize_register_params(register) do
      {:ok, _params} ->
        {:noreply,
         socket
         |> clear_flash()
         |> assign(trigger_submit: true)}

      _ ->
        {:noreply, socket}
    end
  end

  defp load_data(socket, _params) do
    socket
  end

  defp disable(changeset) do
    if changeset.changes != %{} and changeset.valid? do
      "bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
    else
      "bg-indigo-300 cursor-default"
    end
  end
end
