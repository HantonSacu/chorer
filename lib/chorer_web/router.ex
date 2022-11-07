defmodule ChorerWeb.Router do
  use ChorerWeb, :router

  import ChorerWeb.Authentication

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ChorerWeb.Layout.View, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug VBT.Auth
  end

  scope "/", ChorerWeb do
    pipe_through :browser

    post "/register", Auth.Controller, :register, as: :account
    live "/register", Auth.Register, :register, as: :account

    post "/", Auth.Controller, :login, as: :account
    live "/", Auth.Login, :login, as: :account
  end

  scope "/home", ChorerWeb do
    pipe_through [:browser, :require_user]

    live "/", Home, :home, as: :account

    post "/logout", Auth.Controller, :logout, as: :account

    live "/chores", Chores, :chores, as: :account
    live "/friends", Friends, :friends, as: :account
    live "/statistics", Statistics, :statistics, as: :account
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChorerWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChorerWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
