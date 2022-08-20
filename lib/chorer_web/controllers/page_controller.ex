defmodule ChorerWeb.PageController do
  use ChorerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
