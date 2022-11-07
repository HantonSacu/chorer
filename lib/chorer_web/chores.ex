defmodule ChorerWeb.Chores do
  use ChorerWeb, :live_view

  import ChorerWeb.Authentication, only: [check_live_session: 2]
  import Ecto.Changeset

  alias ChorerWeb.CommonComponents.{CheckBox, Flash, TextInput}
  alias Surface.Components.Link

  @changeset change(
               {%{},
                %{
                  title: :string,
                  description: :string,
                  chore_state: :atom,
                  frequency: :integer,
                  repeating?: :boolean,
                  duration: :integer,
                  mental_difficulty: :integer,
                  physical_difficulty: :integer
                }}
             )

  data current_user, :map
  data points, :integer, default: 0
  data changeset, :changeset, default: @changeset
  data chores_state, :list, default: :available, values: [:available, :in_progress, :done]
  data chores, :list, default: []
  data chore_state, :atom, default: "show", values: ["show", "update", "create"]
  data chore_id, :string

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    {:ok, socket |> Surface.init() |> check_live_session(session)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket),
    do: {:noreply, socket |> assign(%{route_params: params}) |> load_data()}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~F"""
    <div class="min-h-screen bg-gradient-to-br from-brevity-gray to-brevity-dark flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="container mx-auto">
        <div class="grid grid-rows-1 flex justify-center justify-content">
          <div class="text-3xl font-extrabold text-black self-center flex flex-col justify-center">
            {#if @chore_state in ["create", "update"]}
              <div class="text-3xl font-extrabold text-white self-center flex ml-10 justify-center">
                {String.capitalize(@chore_state)} Chore
                <Link label="" to="/home/" class="self-center">
                  <img src={Routes.static_path(@socket, "/assets/images/icon.png")}>
                </Link>
                <button :on-click="show_state" value={@chores_state}>
                  <Heroicons.Solid.XCircleIcon class="w-8 h-8" />
                </button>
              </div>
              <div class="bg-black py-8 px-4 shadow sm:rounded-lg sm:px-10">
                <form :on-change="change_chore" :on-submit={"#{@chore_state}_chore"} class="space-y-6">
                  <TextInput form={form = to_form(@changeset, as: :chore)} name={:title} />
                  <TextInput form={form} name={:description} />
                  <TextInput form={form} name={:frequency} />
                  <CheckBox form={form} name={:repeating?} />
                  <TextInput form={form} name={:duration} />
                  <TextInput form={form} name={:mental_difficulty} />
                  <TextInput form={form} name={:physical_difficulty} />

                  <div class="flex flex-row justify-center space-x-4">
                    <button
                      :if={@chore_state == "update"}
                      class="bg-red-500 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"
                      :on-click="delete_chore"
                      data-confirm="Are you sure?"
                    >
                      Delete
                    </button>
                    <button
                      type="submit"
                      class="bg-yellow-500 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"
                    >
                      {String.capitalize(@chore_state)}
                    </button>
                    <button
                      type="button"
                      :if={@chore_state == "update" and @chores_state == :available}
                      class="bg-green-500 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"
                      :on-click="take_on_chore"
                    >
                      Take On
                    </button>
                    <button
                      type="button"
                      :if={@chore_state == "update" and @chores_state == :in_progress}
                      class="bg-blue-500 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"
                      :on-click="finish_chore"
                    >
                      Finish
                    </button>
                    <button
                      type="button"
                      :if={@chore_state == "update" and @chores_state == :done}
                      class="bg-yellow-300 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"
                      :on-click="offer_chore"
                    >
                      Offer
                    </button>
                  </div>
                </form>
              </div>
            {#else}
              <div class="text-3xl font-extrabold text-white self-center flex ml-10 justify-center mb-2">
                <div class="flex flex-col justify-center items-center">
                  Chores
                  <div class="text-xs">
                    {@current_user.first_name} {@current_user.last_name}
                  </div>
                  <div class="text-xs">
                    <span class="text-yellow-300">
                      {@points}
                    </span>
                    Points
                  </div>
                </div>
                <Link label="" to="/home/" class="self-center">
                  <img src={Routes.static_path(@socket, "/assets/images/icon.png")}>
                </Link>
                <button :on-click="create_state">
                  <Heroicons.Solid.PlusCircleIcon class="w-8 h-8" />
                </button>
              </div>
              <div class="flex flex-row">
                <button
                  :for={value <- [:available, :in_progress, :done]}
                  class={"#{if value == @chores_state, do: chores_state_text_color(value), else: "text-white"} py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium"}
                  :on-click="show_state"
                  value={value}
                >
                  {display_chores_state(value)}
                </button>
              </div>
              <Flash type={:error} content={live_flash(@flash, :error)} />
              <Flash type={:info} content={live_flash(@flash, :info)} />
              <div class={"grid grid-rows-#{@chores |> Enum.filter(&(&1.state == @chores_state)) |> length()} gap-1 mt-2"}>
                <button
                  class={"#{chores_state_bg_color(@chores_state)} py-4 px-2 shadow sm:rounded-lg hover:bg-opacity-25 hover:bg-yellow-300"}
                  :for={chore <- Enum.filter(@chores, &(&1.state == @chores_state))}
                  :on-click="update_state"
                  value={chore.id}
                >
                  {chore.title}
                </button>
              </div>
            {/if}
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("create_state", _params, socket) do
    {:noreply, socket |> clear_flash() |> assign(chore_state: "create", changeset: @changeset)}
  end

  def handle_event("show_state", %{"value" => value}, socket) do
    chore_state = String.to_atom(value)
    {:noreply, socket |> clear_flash() |> assign(chore_state: "show", chores_state: chore_state)}
  end

  def handle_event("update_state", %{"value" => id}, socket) do
    socket = clear_flash(socket)
    changeset = change(Enum.find(socket.assigns.chores, &(&1.id == id)) || @changeset, %{})
    {:noreply, assign(socket, chore_state: "update", changeset: changeset, chore_id: id)}
  end

  def handle_event("delete_chore", _params, socket) do
    case Chorer.delete_chore(socket.assigns.chore_id) do
      {:ok, chore} ->
        {:noreply, socket |> put_flash(:info, "Chore #{chore.title} deleted.") |> load_data()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete chore.")}
    end
  end

  def handle_event("take_on_chore", _params, socket) do
    case Chorer.take_on_chore(socket.assigns.current_user.id, socket.assigns.chore_id) do
      {:ok, chore} ->
        {:noreply,
         socket
         |> put_flash(:info, "You've taken on #{chore.title} chore.")
         |> assign(chores_state: :in_progress)
         |> load_data()}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Something went wrong.")}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def handle_event("finish_chore", _params, socket) do
    case Chorer.finish_chore(socket.assigns.current_user.id, socket.assigns.chore_id) do
      {:ok, chore} ->
        {:noreply,
         socket
         |> put_flash(:info, "You've finished #{chore.title} chore.")
         |> assign(chores_state: :done)
         |> load_data()}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Something went wrong.")}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def handle_event("offer_chore", _params, socket) do
    case Chorer.offer_chore(socket.assigns.current_user.id, socket.assigns.chore_id) do
      {:ok, chore} ->
        {:noreply,
         socket
         |> put_flash(:info, "Chore #{chore.title} is available again.")
         |> assign(chores_state: :available)
         |> load_data()}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Something went wrong.")}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end

  def handle_event("change_chore", %{"chore" => chore_params}, socket) do
    socket = clear_flash(socket)

    case normalize_params(chore_params, _required? = false) do
      {:ok, params} ->
        {:noreply, assign(socket, changeset: change(@changeset, params))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("create_chore", %{"chore" => chore_params}, socket) do
    current_user = socket.assigns.current_user

    with {:ok, params} <- normalize_params(chore_params),
         {:ok, _chore} <- Chorer.create_chore(current_user.id, params) do
      {:noreply, socket |> put_flash(:info, "Chore #{params.title} is added.") |> load_data()}
    else
      {:error, changeset} -> {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("update_chore", %{"chore" => chore_params}, socket) do
    with {:ok, params} <- normalize_params(chore_params),
         {:ok, _chore} <- Chorer.edit_chore(socket.assigns.chore_id, params) do
      {:noreply, socket |> put_flash(:info, "Chore #{params.title} is updated.") |> load_data()}
    else
      {:error, changeset} -> {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp load_data(socket) do
    current_user = socket.assigns.current_user

    assign(socket,
      points: Chorer.account_points(current_user.id) || 0,
      chore_state: "show",
      chores: Chorer.account_chores(current_user.id)
    )
  end

  defp normalize_params(params, required? \\ true) do
    string = if required?, do: {:string, required: true}, else: :string
    integer = if required?, do: {:integer, required: true}, else: :integer

    VBT.Validation.normalize(params,
      title: string,
      description: string,
      frequency: integer,
      repeating?: :boolean,
      duration: integer,
      mental_difficulty: integer,
      physical_difficulty: integer
    )
  end

  defp display_chores_state(value) do
    value |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  end

  defp chores_state_text_color(:available), do: "text-yellow-300"
  defp chores_state_text_color(:in_progress), do: "text-green-300"
  defp chores_state_text_color(:done), do: "text-blue-300"

  defp chores_state_bg_color(:available), do: "bg-yellow-300"
  defp chores_state_bg_color(:in_progress), do: "bg-green-300"
  defp chores_state_bg_color(:done), do: "bg-blue-300"
end
