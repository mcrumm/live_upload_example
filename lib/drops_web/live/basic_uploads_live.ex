defmodule DropsWeb.BasicUploadsLive do
  use DropsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:exhibit, accept: ~w(video/* image/*), max_entries: 6, chunk_size: 256_000)}
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
    uploaded_files =
      consume_uploaded_entries(socket, :exhibit, fn %{path: path}, _entry ->
        dest = Path.join(Drops.uploads_priv_dir(), Path.basename(path))
        File.cp!(path, dest)
        Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end
end
