defmodule DropsWeb.UploadsLive.Auto do
  @moduledoc """
  Demonstrates automatic uploads with the Phoenix Channels uploader.
  """
  use DropsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:exhibit,
       accept: :any,
       max_entries: 10,
       max_file_size: 100_000_000,
       chunk_size: 1_024,
       auto_upload: true,
       progress: &handle_progress/3
     )}
  end

  # with auto_upload: true we can consume files here
  defp handle_progress(:exhibit, entry, socket) do
    if entry.done? do
      uuid =
        consume_uploaded_entry(socket, entry, fn _meta ->
          entry.uuid
        end)

      {:noreply, update(socket, :uploaded_files, &[uuid | &1])}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :exhibit, ref)}
  end
end
