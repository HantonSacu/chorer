defmodule ChorerWeb.CommonComponents.Modal do
  use ChorerWeb, :component

  alias Surface.Components.LivePatch

  slot default

  prop title, :string
  prop close_path, :string, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div class="fixed z-10 inset-0 overflow-y-auto">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <!-- Background overlay -->
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true" />

        <!-- This element is to trick the browser into centering the modal contents. -->
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

        <!-- Modal panel -->
        <div class="inline-block align-bottom bg-brevity-light rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:w-full sm:p-6">
          <div class="flex flex-col space-y-4">
            <div class="flex flex-row items-center justify-between">
              <div>{@title}</div>

              <LivePatch to={@close_path} class="self-end text-gray-600 hover:text-black">
                <Heroicons.Solid.XCircleIcon class="w-8 h-8" />
              </LivePatch>
            </div>

            <div class="w-full border-t border-gray-300" />

            <#slot />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
