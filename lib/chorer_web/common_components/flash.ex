defmodule ChorerWeb.CommonComponents.Flash do
  use Surface.Component

  prop type, :atom, required: true, values: [:error, :info]
  prop content, :string

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div :if={@content} class={"rounded-md p-1 #{bg_class(@type)}"}>
      <div class="flex">
        <div class="flex-shrink-0">{icon(@type)}</div>
        <div class="ml-3">
          <p class={"text-sm font-medium #{text_class(@type)}"}>
            {@content}
          </p>
        </div>
      </div>
    </div>
    """
  end

  defp icon(:info = _type) do
    assigns = %{}

    ~F"""
    <!-- Heroicon name: solid/check-circle -->
    <svg
      class="h-5 w-5 text-green-800"
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 20 20"
      fill="currentColor"
      aria-hidden="true"
    >
      <path
        fill-rule="evenodd"
        d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  defp icon(:error = _type) do
    assigns = %{}

    ~F"""
    <!-- Heroicon name: solid/x-circle -->
    <svg
      class="h-5 w-5 text-red-400"
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 20 20"
      fill="currentColor"
      aria-hidden="true"
    >
      <path
        fill-rule="evenodd"
        d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  defp text_class(:error = _type), do: "text-red-700"
  defp text_class(:info = _type), do: "text-green-800"

  defp bg_class(:error = _type), do: "bg-red-50"
  defp bg_class(:info = _type), do: "bg-green-50"
end
