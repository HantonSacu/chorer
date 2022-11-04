# credo:disable-for-this-file VBT.Credo.Check.Consistency.FileLocation
defmodule ChorerWeb.CommonComponents.Table do
  use ChorerWeb, :component

  prop columns, :list, required: true

  slot default
  slot pagination

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div class="flex flex-col">
      <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
          <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
            <div class="table min-w-full">
              <thead>
                <div
                  :for={column <- @columns}
                  scope="col"
                  class="table-cell px-6 py-3 text-left text-xs font-medium bg-brevity-dark text-brevity-light uppercase tracking-wider"
                >
                  {column}
                </div>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <#slot />
              </tbody>
            </div>
            <#slot name="pagination" />
          </div>
        </div>
      </div>
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.TableRow do
  use ChorerWeb, :component

  alias Surface.Components.LiveRedirect

  prop columns, :list, required: true
  prop path, :string
  prop show_delete, :boolean, default: false
  prop show_promote, :boolean, default: false
  prop show_liked, :boolean, default: false

  slot delete
  slot promote
  slot liked

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    {#if is_nil(@path)}
      <div class="table-row bg-white hover:bg-gray-100">
        {render_columns(assigns)}
      </div>
    {#else}
      <LiveRedirect to={@path} class="table-row bg-white hover:bg-gray-100">
        {render_columns(assigns)}
      </LiveRedirect>
    {/if}
    """
  end

  defp render_columns(assigns) do
    ~F"""
    <div :if={@show_liked} class="table-cell" align="center">
      <#slot name="liked" />
    </div>
    <div
      :for={column <- @columns}
      title={column}
      class="max-w-md table-cell px-6 py-4 text-sm text-gray-500"
      style="white-space: nowrap; text-overflow: ellipsis; overflow: hidden;"
    >
      {column}
    </div>

    <div :if={@show_delete} class="table-cell">
      <#slot name="delete" />
    </div>
    <div :if={@show_promote} class="table-cell">
      <#slot name="promote" />
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.TableFilterItem do
  use ChorerWeb, :component

  alias Surface.Components.LivePatch

  prop name, :string, required: true
  prop path, :string, required: true
  prop is_current, :boolean, default: false

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <LivePatch to={@path} class={class(@is_current)}>
      {@name}
    </LivePatch>
    """
  end

  defp class(true = _is_current),
    do: "text-brevity-dark px-3 py-2 font-medium text-sm border-b-2 border-brevity-dark"

  defp class(false = _is_current),
    do: "text-gray-500 hover:text-gray-700 px-3 py-2 font-medium text-sm rounded-md"
end
