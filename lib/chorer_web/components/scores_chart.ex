defmodule ChorerWeb.Components.ScoresChart do
  @moduledoc """
  Conveniences for translating and building error messages.
  """
  use ChorerWeb, :live_component

  alias Contex.{Dataset, PieChart, Plot}

  prop current_user, :map, required: true
  prop period, :atom, required: true

  data scores, :list, default: []
  data svg, :map, default: %{}

  def update(assigns, socket) do
    {:ok, load_data(Surface.init(socket), assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div style="transform:scale(0.27);translate:-1% -35%;">
      {@svg}
    </div>
    """
  end

  defp load_data(socket, assigns) do
    scores = Chorer.scores(assigns.current_user, assigns.period)
    dataset = scores |> Dataset.new(["Name", "Scores"]) |> Dataset.title("Statistics")
    svg = create_svg(dataset)
    data = %{scores: scores, svg: svg}
    assign(socket, Map.merge(assigns, data))
  end

  defp create_svg(dataset) do
    opts = [
      mapping: %{category_col: "Name", value_col: "Scores"},
      data_labels: false,
      legend_setting: :legend_right
    ]

    {:safe, list} = Plot.to_svg(Plot.new(dataset, PieChart, 600, 400, opts))
    {:safe, List.update_at(list, 3, fn _ -> svg_style() end)}
  end

  defp svg_style do
    "<style type=\"text/css\"><![CDATA[\n  text {fill: white}\n  line {stroke: white}\n]]></style>\n"
  end
end
