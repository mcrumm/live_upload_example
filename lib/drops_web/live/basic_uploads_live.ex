defmodule DropsWeb.BasicUploadsLive do
  use DropsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:exhibit,
       accept: ~w(video/* image/*),
       max_entries: 6,
       chunk_size: 64 * 1_024
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :exhibit, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, DropsWeb.Uploads.consume_prepend_entries(socket, :exhibit, :uploaded_files)}
  end
end
