# credo:disable-for-this-file VBT.Credo.Check.Consistency.FileLocation
defmodule ChorerWeb.Statistics do
  use ChorerWeb, :live_view

  import ChorerWeb.Authentication, only: [check_live_session: 2]

  alias ChorerWeb.Components.ScoresChart
  alias Surface.Components.Link

  data current_user, :map
  data chores, :list, default: []
  data period, :atom, default: :today, values: [:today, :this_week, :this_month, :all_time]

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
        <div class="grid grid-rows-1 flex justify-center justify-content" style="translate:0% 20%;">
          <div class="text-3xl font-extrabold text-white self-center flex ml-10 justify-center mb-2">
            <div class="flex flex-col justify-center items-center">
              Statistics
              <div class="text-xs">
                {@current_user.first_name} {@current_user.last_name}
              </div>
              <div class="text-xs">
                <span class="text-yellow-300">
                  {length(@current_user.friends)}
                </span>
                Friends
              </div>
            </div>
            <Link label="" to="/home/" class="self-center">
              <img src={Routes.static_path(@socket, "/assets/images/icon.png")}>
            </Link>
          </div>
          <div class="flex flex-row text-white justify-center">
            <button
              :for={value <- [:today, :this_week, :this_month, :all_time]}
              class={"#{if value == @period, do: "text-yellow-300"} py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium"}
              :on-click="show_chart"
              value={value}
            >
              {display_stats_state(value)}
            </button>
          </div>
          <ScoresChart id={"scores_#{@current_user.id}"} current_user={@current_user} period={@period} />
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("show_chart", %{"value" => value}, socket) do
    period = String.to_atom(value)
    {:noreply, socket |> clear_flash() |> assign(period: period)}
  end

  defp load_data(socket) do
    socket
  end

  defp display_stats_state(value) do
    value |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  end
end
