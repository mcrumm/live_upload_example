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
    anything = consume_uploaded_entries(socket, :anything, &do_consume_upload(&1, &2, socket))
    images = consume_uploaded_entries(socket, :images, &do_consume_upload(&1, &2, socket))

    {:noreply, update(socket, :uploaded_files, &(&1 ++ anything ++ images))}
  end

  defp do_consume_upload(%{path: path}, _entry, socket) do
    dest = Path.join(Drops.uploads_priv_dir(), Path.basename(path))
    File.cp!(path, dest)
    Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
  end
end
