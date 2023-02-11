defmodule DropsWeb.CropprLive do
  use DropsWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:avatar_path, nil)
     |> allow_upload(:avatar, accept: ~w(image/*), max_entries: 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _, socket) do
    {:noreply,
     socket
     |> DropsWeb.Uploads.consume_replace_entries(:avatar, :avatar_path)
     |> push_event("croppr:destroy", %{"name" => "avatar"})}
  end
end
