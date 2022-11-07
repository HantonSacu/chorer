defmodule ChorerWeb.Home do
  use ChorerWeb, :live_view

  import ChorerWeb.Authentication, only: [check_live_session: 2]

  alias Surface.Components.Link

  data current_user, :map
  data trigger_submit, :boolean, default: false

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    {:ok, socket |> Surface.init() |> check_live_session(session)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket),
    do: {:noreply, assign(socket, %{route_params: params})}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~F"""
    <div class="min-h-screen bg-gradient-to-br from-brevity-gray to-brevity-dark flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="container mx-auto">
        <div class="grid grid-rows-5 flex justify-center justify-content items-strech">
          <div class="text-3xl font-extrabold text-white self-center flex justify-center">
            <Link label="" to="/home/" class="self-center">
              <img src={Routes.static_path(@socket, "/assets/images/icon.png")}>
            </Link>
          </div>
          <Link label="" to="/home/chores" class="self-center">
            <div class="px-12 py-4 bg-yellow-300 text-center rounded-2xl font-extrabold text-white hover:bg-opacity-25 hover:text-yellow-300">
              Chores
            </div>
          </Link>
          <Link label="" to="/home/friends" class="self-center">
            <div class="px-12 py-4 bg-yellow-400 text-center rounded-2xl font-extrabold text-white hover:bg-opacity-25 hover:text-yellow-400">
              Friends
            </div>
          </Link>
          <Link label="" to="/home/statistics" class="self-center">
            <div class="px-14 py-4 bg-yellow-500 text-center rounded-2xl font-extrabold text-white hover:bg-opacity-25 hover:text-yellow-500">
              Statistics
            </div>
          </Link>
          <Link label="Logout" to="/home/logout" method={:post} class="self-center flex justify-center">
            <button class="py-2 px-4 border border-1 border-white rounded-2xl shadow-sm text-sm font-light text-white bg-gray-600 hover:bg-brevity-light hover:text-brevity-dark focus:outline-none">
              Logout
            </button>
          </Link>
        </div>
      </div>
    </div>
    """
  end
end
