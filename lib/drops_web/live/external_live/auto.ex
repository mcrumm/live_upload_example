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
       max_file_size: 100_000_000,
       chunk_size: 1_024,
       auto_upload: true,
       progress: &handle_progress/3,
       external: &presigned_upload/2
     )}
  end

  # with auto_upload: true we can consume files here
  defp handle_progress(:exhibit, entry, socket) do
    if entry.done? do
      consume_uploaded_entry(socket, entry, fn %{} = meta ->
        IO.inspect({entry, meta})
      end)
    end

    {:noreply, socket}
  end

  defp presigned_upload(entry, socket) do
    meta = %{uploader: "NoJitter", name: entry.client_name, ref: entry.ref, uuid: entry.uuid}
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
