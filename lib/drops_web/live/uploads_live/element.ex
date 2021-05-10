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
    [file] = consume_uploaded_entries(socket, :file, fn entry, _ -> entry end)
    {:noreply, update_file(socket, file)}
  end

  @impl true
  def handle_event("remove", _, socket) do
    {:noreply, update_file(socket, nil)}
  end

  defp update_file(socket, file) do
    update(socket, :selected_file, fn _ -> file end)
  end
end
