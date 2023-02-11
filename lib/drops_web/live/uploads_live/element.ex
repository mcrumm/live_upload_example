defmodule DropsWeb.UploadsLive.Element do
  use DropsWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:selected_file, nil)
     |> allow_upload(:file, accept: :any, max_entries: 1)}
  end

  @impl true
  def handle_event("change", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", _, socket) do
    {:noreply, DropsWeb.Uploads.consume_replace_entries(socket, :file, :selected_file)}
  end

  @impl true
  def handle_event("remove", _, socket) do
    {:noreply, assign(socket, :selected_file, nil)}
  end
end
