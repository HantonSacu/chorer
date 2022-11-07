defmodule ChorerWeb.Friends do
  use ChorerWeb, :live_view

  import ChorerWeb.Authentication, only: [check_live_session: 2]

  alias ChorerWeb.CommonComponents.Flash
  alias Surface.Components.Link

  data current_user, :map
  data friends, :list, default: []
  data accounts, :list, default: []

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
        <div
          class="grid grid-rows-1 flex justify-center justify-content items-strech"
          ,
          style="translate: 0% 20%;"
        >
          <div class="text-3xl font-extrabold text-white self-center flex ml-10 justify-center mb-2">
            <div class="flex flex-col justify-center items-center">
              Friends
              <div class="text-xs">
                {@current_user.first_name} {@current_user.last_name}
              </div>
              <div class="text-xs">
                <span class="text-yellow-300">
                  {length(@friends)}
                </span>
                Friends
              </div>
            </div>
            <Link label="" to="/home/" class="self-center">
              <img src={Routes.static_path(@socket, "/assets/images/icon.png")}>
            </Link>
            <button :on-click="create_state">
              <Heroicons.Solid.PlusCircleIcon class="w-8 h-8" />
            </button>
          </div>
          <Flash type={:error} content={live_flash(@flash, :error)} />
          <Flash type={:info} content={live_flash(@flash, :info)} />
          <div class={"grid grid-rows-#{length(@friends) + length(@accounts) + 2} text-white"}>
            <div class="font-extrabold text-center">
              Friends
            </div>
            <div :for={friend <- @friends} class="text-sm flex justify-between">
              <div class="m-1">
                {friend.first_name} {friend.last_name}
              </div>
              <button
                type="button"
                :on-click="unfriend"
                value={friend.id}
                class="bg-red-500 px-1 py-1 m-1 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"
              >
                Unfriend
              </button>
            </div>
            <div class="font-extrabold">
              Others
            </div>
            <div :for={account <- @accounts} class="text-sm flex justify-between">
              <div class="m-1">
                {account.first_name} {account.last_name}
              </div>
              <button
                type="button"
                :on-click={friend_action(@current_user, account)}
                value={account.id}
                class={"#{friend_action_bg(@current_user, account)} px-1 py-1 border border-transparent rounded-md shadow-sm text-sm font-medium text-white"}
              >
                {String.capitalize(friend_action(@current_user, account))}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("befriend", %{"value" => id}, socket) do
    current_user = socket.assigns.current_user

    case Chorer.befriend(current_user.id, id) do
      :ok -> {:noreply, socket |> put_flash(:info, "Friend added.") |> load_data()}
      {:error, _changeset} -> put_flash(socket, :error, "Something went wrong.")
    end
  end

  def handle_event("unfriend", %{"value" => id}, socket) do
    current_user = socket.assigns.current_user

    case Chorer.unfriend(current_user.id, id) do
      :ok -> {:noreply, socket |> put_flash(:info, "Friend removed.") |> load_data()}
      {:error, _changeset} -> put_flash(socket, :error, "Something went wrong.")
    end
  end

  defp load_data(socket) do
    current_user = socket.assigns.current_user
    friends = Chorer.account_friends(socket.assigns.current_user.id)
    accounts = get_accounts(current_user, friends)

    assign(socket, friends: friends, accounts: accounts)
  end

  defp get_accounts(current_user, friends) do
    ids = Enum.map(friends, & &1.id) ++ [current_user.id]
    Enum.filter(Chorer.accounts(), &(&1.id not in ids))
  end

  defp friend_action(%{friends: friends}, account) do
    if Enum.any?(friends, &(&1.id == account.id)), do: "unfriend", else: "befriend"
  end

  defp friend_action_bg(%{friends: friends}, account) do
    if Enum.any?(friends, &(&1.id == account.id)), do: "bg-red-500", else: "bg-green-500"
  end
end
