# credo:disable-for-this-file VBT.Credo.Check.Consistency.FileLocation
defmodule ChorerWeb.CommonComponents.TextInput do
  use Surface.Component

  import ChorerWeb.Error.Helpers
  import Phoenix.HTML.Form

  prop form, :form, required: true
  prop name, :atom, required: true
  prop debounce, :integer, default: 300
  prop maxlength, :string
  prop rows, :integer, default: 0
  prop disabled, :boolean, default: false
  prop readonly, :boolean, default: false
  prop text_color, :string, default: "text-gray-700"
  prop style, :string
  prop label?, :boolean, default: true
  prop label_name, :string

  prop field_type, :atom,
    default: :text_input,
    values: [:text_input, :email_input, :password_input, :textarea]

  prop placeholder, :string

  # Phoenix never reuses data from passwords
  # in order for LV trigger action to work for
  # password submissions value has to be set explicitly
  prop explicit_value_set, :boolean, default: false

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div>
      {if @label? do
        label(@form, @label_name || @name, class: "block text-sm font-medium #{@text_color}")
      end}
      <div class="mt-1 relative rounded-md shadow-sm">
        {apply(Phoenix.HTML.Form, @field_type, [
          @form,
          @name,
          [
            style: @style,
            class: "#{border_classes(has_error?(@form, @name))}",
            "phx-debounce": @debounce,
            maxlength: @maxlength,
            rows: @rows,
            disabled: @disabled,
            readonly: @readonly,
            placeholder: @placeholder
          ] ++ explicit_value_set(@form, @name, @explicit_value_set)
        ])}
      </div>
      {error_tag(@form, @name)}
    </div>
    """
  end

  defp border_classes do
    """
    appearance-none block w-full px-3 py-2 border
    rounded-md shadow-sm sm:text-sm focus:outline-none
    """
  end

  defp border_classes(true = _has_error),
    do: "#{border_classes()} border-red-300 text-red-900 focus:ring-red-500 focus:border-red-500"

  defp border_classes(false = _has_error),
    do: "#{border_classes()} placeholder-gray-400 focus:ring-indigo-500 focus:border-indigo-500"

  defp has_error?(form, field), do: Keyword.has_key?(form.errors, field)

  defp explicit_value_set(_, _, false), do: []
  defp explicit_value_set(form, name, true), do: [value: input_value(form, name)]
end

for type <- ~w(email password) do
  defmodule Module.concat([ChorerWeb.CommonComponents, "#{String.capitalize(type)}Input"]) do
    use Surface.Component

    alias ChorerWeb.CommonComponents.TextInput

    prop form, :form, required: true
    prop name, :atom, required: true
    prop debounce, :integer, default: 300
    prop maxlength, :string
    prop disabled, :boolean, default: false
    prop placeholder, :string
    prop explicit_value_set, :boolean, default: type == "password"

    @impl Phoenix.LiveComponent
    def render(assigns) do
      attributes =
        assigns
        |> Map.take(~w(form name debounce maxlength disabled placeholder explicit_value_set)a)
        |> Map.put(:field_type, unquote(String.to_atom("#{type}_input")))

      ~F"""
      <TextInput {...attributes} />
      """
    end
  end
end

defmodule ChorerWeb.CommonComponents.TextDarkInput do
  use Surface.Component

  import ChorerWeb.Error.Helpers
  import Phoenix.HTML.Form

  prop form, :form, required: true
  prop name, :atom, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div>
      <div class="bg-brevity-dark border border-black rounded-lg focus-within:border-brevity-yellow focus-within:border-2">
        {label(@form, @name, class: "px-3 text-xs text-brevity-yellow")}
        {text_input(@form, @name,
          class:
            "w-full rounded-lg bg-transparent text-brevity-light px-3 py-1 focus:outline-none caret-brevity-yellow",
          "phx-debounce": 500,
          placeholder: Phoenix.Naming.humanize(@name)
        )}
      </div>
      {error_tag(@form, @name)}
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.PasswordDarkInput do
  use Surface.Component

  import ChorerWeb.Error.Helpers
  import Phoenix.HTML.Form

  prop form, :form, required: true
  prop name, :atom, required: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div>
      <div class="bg-brevity-dark border border-black rounded-lg focus-within:border-brevity-yellow focus-within:border-2">
        {label(@form, @name, class: "px-3 text-xs text-brevity-yellow")}
        {password_input(@form, @name,
          class:
            "w-full rounded-lg bg-transparent text-brevity-light px-3 py-1 focus:outline-none caret-brevity-yellow",
          "phx-debounce": 100,
          placeholder: "••••••••",
          value: input_value(@form, @name)
        )}
      </div>
      {error_tag(@form, @name)}
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.CheckBox do
  use Surface.Component

  import Phoenix.HTML.Form

  prop form, :form, required: true
  prop name, :atom, required: true
  prop disabled, :boolean, default: false

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div>
      {checkbox(@form, @name,
        class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded",
        disabled: @disabled
      )}
      {label(@form, @name, class: "text-base font-medium text-gray-900 sm:text-sm sm:text-gray-700")}
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.SelectInput do
  use ChorerWeb, :component

  import ChorerWeb.Error.Helpers
  import Phoenix.HTML.Form

  prop form, :form, required: true
  prop name, :atom, required: true
  prop options, :list, default: []
  prop disabled, :boolean, default: false
  prop selected, :string
  prop style, :string

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div>
      {label(@form, @name, class: "block text-sm font-medium text-gray-700")}
      <div class="mt-1 sm:mt-0 sm:col-span-2">
        {select(@form, @name, @options,
          disabled: @disabled,
          selected: @selected,
          style: @style,
          class:
            "mt-1 apperance-none block w-full px-1 py-2.5 border focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border-gray-300 rounded-md"
        )}
        <i :if={not @disabled} />
      </div>
      {error_tag(@form, @name)}
    </div>
    """
  end
end

defmodule ChorerWeb.CommonComponents.DateInput do
  use ChorerWeb, :component

  import ChorerWeb.Error.Helpers
  import Phoenix.HTML.Form

  prop form, :form, required: true
  prop name, :atom, required: true
  prop min, :string
  prop max, :string
  prop disabled, :boolean, default: false
  prop required, :boolean, default: false
  prop label?, :boolean, default: true

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <div>
      {if @label? do
        label(@form, @name, Phoenix.Naming.humanize(@name),
          class: "block text-sm font-medium text-gray-700"
        )
      end}
      <div class="mt-1 sm:mt-0 sm:col-span-2">
        {date_input(@form, @name, disabled: @disabled, min: @min, max: @max, required: @required)}
      </div>
      <div
        :if={@name == :free_until and not selected?(@form)}
        class="text-xs font-medium text-gray-500"
      >Unlimited if not set</div>
      {error_tag(@form, @name)}
    </div>
    """
  end

  defp selected?(form), do: Map.has_key?(form.source.changes, :free_until)
end
