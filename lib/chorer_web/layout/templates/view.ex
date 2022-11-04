# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule ChorerWeb.Layout.View do
  use ChorerWeb, :view

  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
