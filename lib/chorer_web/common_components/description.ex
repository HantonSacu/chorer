# credo:disable-for-this-file VBT.Credo.Check.Consistency.FileLocation
defmodule ChorerWeb.CommonComponents.DescriptionList do
  use ChorerWeb, :component

  slot default

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div class="w-full px-6">
      <dl class="divide-y divide-gray-200">
        <#slot />
      </dl>
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.DescriptionFlatRow do
  use ChorerWeb, :component

  prop name, :string, required: true
  prop value, :string, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div class="flex flex-row py-5">
      <dt class="flex-1 text-sm font-bold text-gray-500">
        {@name}
      </dt>
      <dd class="flex-1 mt-1 text-sm text-gray-900">
        {@value}
      </dd>
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.DescriptionStackRow do
  use ChorerWeb, :component

  prop name, :string, required: true
  prop value, :string, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div class="py-5">
      <dt class="text-sm font-bold text-gray-500">
        {@name}
      </dt>
      <dd class="mt-1 text-sm text-gray-900">
        {@value}
      </dd>
    </div>
    """
  end
end
