# credo:disable-for-this-file VBT.Credo.Check.Consistency.FileLocation
defmodule ChorerWeb.CommonComponents.PaginationLayout do
  use ChorerWeb, :component

  slot default

  prop count, :integer, required: true
  prop page_size, :integer, required: true
  prop current_page, :integer, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div
      :if={@count != 0}
      class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6"
    >
      <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
        <div>
          <p class="text-sm text-gray-700">
            Showing
            <span class="font-medium">
              {(@current_page - 1) * @page_size + 1}
            </span>
            to
            <span class="font-medium">
              {min((@current_page - 1) * @page_size + @page_size, @count)}
            </span>
            of
            <span class="font-medium">
              {@count}
            </span>
            results
          </p>
        </div>
        <div>
          <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
            <#slot />
          </nav>
        </div>
      </div>
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.PaginationLink do
  use ChorerWeb, :component

  alias Surface.Components.LivePatch

  slot default

  prop path, :string, required: true
  prop is_current, :boolean, default: false

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <LivePatch to={@path} class={class(@is_current)}>
      <#slot />
    </LivePatch>
    """
  end

  defp class(false = _is_current) do
    "bg-white border-gray-300 text-gray-500 hover:bg-gray-50 relative inline-flex items-center px-4 py-2 border text-sm font-medium"
  end

  defp class(true = _is_current) do
    "z-10 bg-gray-100 border-gray-600 text-gray-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium"
  end
end

defmodule ChorerWeb.CommonComponents.Pagination do
  use ChorerWeb, :component

  alias ChorerWeb.CommonComponents.{PaginationLayout, PaginationLink}

  prop count, :integer, required: true
  prop page_size, :integer, required: true
  prop current_page, :integer, required: true
  prop page_to_path, :fun, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <PaginationLayout
      :if={@count > 0}
      count={@count}
      page_size={@page_size}
      current_page={@current_page}
    >
      <PaginationLink :if={@current_page != 1} path={@page_to_path.(@current_page - 1)}>
        <span class="sr-only">Previous</span>
        <Heroicons.Solid.ChevronLeftIcon />
      </PaginationLink>

      <PaginationLink :if={@current_page - 2 > 1} path={@page_to_path.(1)}>
        1
      </PaginationLink>

      <PaginationLink :if={@current_page - 3 > 1} path={@page_to_path.(@current_page - 3)}>
        ...
      </PaginationLink>

      <PaginationLink
        :for={page <- max(1, @current_page - 2)..min(@current_page + 2, last_page(@count, @page_size))}
        path={@page_to_path.(page)}
        is_current={page == @current_page}
      >
        {page}
      </PaginationLink>

      <PaginationLink
        :if={@current_page + 3 < last_page(@count, @page_size)}
        path={@page_to_path.(@current_page + 3)}
      >
        ...
      </PaginationLink>

      <PaginationLink
        :if={@current_page + 2 < last_page(@count, @page_size)}
        path={@page_to_path.(last_page(@count, @page_size))}
      >
        {last_page(@count, @page_size)}
      </PaginationLink>

      <PaginationLink
        :if={@current_page != last_page(@count, @page_size)}
        path={@page_to_path.(@current_page + 1)}
      >
        <span class="sr-only">Next</span>
        <Heroicons.Solid.ChevronRightIcon />
      </PaginationLink>
    </PaginationLayout>
    """
  end

  defp last_page(count, page_size), do: (count / page_size) |> Float.ceil() |> round()
end
