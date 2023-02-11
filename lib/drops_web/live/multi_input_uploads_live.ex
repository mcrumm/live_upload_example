defmodule DropsWeb.MultiInputUploadsLive do
  use DropsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:images, accept: ~w(image/*), max_entries: 10)
     |> allow_upload(:anything, accept: :any, max_entries: 5)}
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"upload" => "images", "ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("cancel-upload", %{"upload" => "anything", "ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :anything, ref)}
  end

  @impl true
  def handle_event("cancel-upload", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _, socket) do
    {:noreply,
     socket
     |> DropsWeb.Uploads.consume_append_entries(:anything, :uploaded_files)
     |> DropsWeb.Uploads.consume_append_entries(:images, :uploaded_files)}
  end
end
