defmodule ChorerWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ChorerWeb, :controller
      use ChorerWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller(_opts) do
    quote do
      use Phoenix.Controller, namespace: ChorerWeb

      import Plug.Conn
      import ChorerWeb.Gettext
      alias ChorerWeb.Router.Helpers, as: Routes
    end
  end

  def view(opts) do
    quote do
      default_opts = [root: Path.relative_to_cwd(__DIR__), path: ""]

      use Phoenix.View, Keyword.merge(default_opts, unquote(opts))

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view(opts) do
    # Layaout is not set here for Surface component
    quote do
      use Surface.LiveView, unquote(opts)
      use Phoenix.HTML

      alias Phoenix.LiveView.Socket

      unquote(view_helpers())
    end
  end

  def live_component(_opts) do
    quote do
      use Surface.LiveComponent

      unquote(view_helpers())
    end
  end

  def component(_opts) do
    quote do
      use Surface.Component
      use Phoenix.HTML

      unquote(view_helpers())
    end
  end

  def router(_opts) do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ChorerWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Phoenix.HTML.FormData, only: [to_form: 2]
      import ChorerWeb.Error.Helpers
      import ChorerWeb.Gettext

      alias ChorerWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which), do: apply_fun(which)

  defp apply_fun(fun) when is_atom(fun), do: apply_fun({fun, []})
  defp apply_fun({fun, opts}), do: apply(__MODULE__, fun, [opts])
end
