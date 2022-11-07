defmodule ChorerWeb.Account.ActivateAccount do
  use ChorerWeb, :live_view

  alias ChorerWeb.CommonComponents.Flash

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket),
    do: {:noreply, socket |> assign(%{route_params: params}) |> load_data()}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~F"""
    <div class="min-h-screen flex flex-col justify-center py-12 sm:px-6 lg:px-8 bg-gradient-to-br from-brevity-gray to-brevity-dark">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <img src={Routes.static_path(@socket, "/assets/images/logo.png")}>
      </div>

      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="mt-8 px-4 sm:rounded-lg sm:px-10">
          <Flash type={:error} content={live_flash(@flash, :error)} />
          <Flash type={:info} content={live_flash(@flash, :info)} />
        </div>
      </div>
    </div>
    """
  end

  # Using hack from https://elixirforum.com/t/shortcomings-in-liveview-are-there-any-i-should-look-out-for/31831/10
  # to avoid calling `Brevity.activate_account/1` two times because of live view nature and rendering both success
  # and failure flash message on the same screen.
  defp load_data(%{assigns: %{route_params: params}} = socket) do
    if connected?(socket) do
      case Chorer.activate_account(params["token"]) do
        {:ok, _account} ->
          put_flash(socket, :info, "You have sucessfully activated your account.")

        {:error, _} ->
          put_flash(socket, :error, "Account token is invalid or has expired.")
      end
    else
      socket
    end
  end
end
