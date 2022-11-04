# credo:disable-for-this-file VBT.Credo.Check.Consistency.FileLocation
defmodule ChorerWeb.CommonComponents.DeleteButton do
  use ChorerWeb, :component

  prop text, :string, required: true
  prop data_confirm, :string, default: "Are you sure?"

  @impl Surface.Component
  def render(assigns) do
    ~F"""
    <button
      type="submit"
      data-confirm={@data_confirm}
      class="min-w-full py-2 px-4 border border-1 border-brevity-red rounded-2xl shadow-sm text-sm font-light text-brevity-red bg-transparent hover:bg-brevity-red hover:text-white focus:outline-none"
    >
      {@text}
    </button>
    """
  end
end

defmodule ChorerWeb.CommonComponents.SuccessButton do
  use ChorerWeb, :component

  prop text, :string, required: true

  @impl Surface.Component
  def render(assigns) do
    ~F"""
    <button
      type="submit"
      class="min-w-full py-2 px-4 border border-1 border-brevity-green rounded-2xl shadow-sm text-sm font-light text-brevity-green bg-transparent hover:bg-brevity-green hover:text-white focus:outline-none"
    >
      {@text}
    </button>
    """
  end
end

defmodule ChorerWeb.CommonComponents.AcceptButton do
  use ChorerWeb, :component

  prop text, :string, required: true

  @impl Surface.Component
  def render(assigns) do
    ~F"""
    <button
      type="submit"
      class="min-w-full py-2 px-4 border border-1 border-brevity-teal rounded-2xl shadow-sm text-sm font-light text-brevity-teal bg-transparent hover:bg-brevity-teal hover:text-white focus:outline-none"
    >
      {@text}
    </button>
    """
  end
end
