defmodule DropsWeb.ExternalLive.Auto do
  @moduledoc """
  Demonstrates automatic uploads with an external uploader.
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
       max_file_size: 100 * 1_024 * 1_024,
       chunk_size: 1_024,
       auto_upload: true,
       progress: &handle_progress/3,
       external: &presigned_upload/2
     ), temporary_assigns: [uploaded_files: []]}
  end

  # with auto_upload: true we can consume files here
  defp handle_progress(:exhibit, entry, socket) do
    {:noreply,
     DropsWeb.Uploads.update_on_done(socket, entry, :uploaded_files, fn
       %{uuid: uuid} = _meta, uploaded_files ->
         [uuid | uploaded_files]
     end)}
  end

  defp presigned_upload(entry, socket) do
    meta = %{uploader: "NoWait", name: entry.client_name, ref: entry.ref, uuid: entry.uuid}
    {:ok, meta, socket}
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
