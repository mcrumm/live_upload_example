defmodule DropsWeb.UploadsLive.MediaStream do
  use DropsWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:notes,
        accept: ~w(audio/*),
        max_size: 100_000_000,
        auto_upload: true,
        progress: &handle_progress/3
      )

    {:ok, socket}
  end

  # with auto_upload: true we can consume files here
  defp handle_progress(:notes, entry, socket) do
    if entry.done? do
      path =
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          dest = Path.join(Drops.uploads_priv_dir(), Path.basename(path))
          File.cp!(path, dest)
          Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
        end)

      {:noreply, update(socket, :uploaded_files, &[path | &1])}
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
    {:noreply, cancel_upload(socket, :notes, ref)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h2>MediaStream Demo</h2>
    <p>Within this demonstration you can record an audio sample and upload it to the server.</p>
    <p>Thanks to <a href="https://twitter.com/philnash">@philnash</a> for the <a href="https://www.twilio.com/blog/mediastream-recording-api">example that inspired this demo</a>.</p>

    <div id="media-stream-recorder-demo" class="controls" phx-hook="MediaStreamRecorder" phx-update="ignore">
      <button type="button" id="mic">Get Mic</button>
      <button type="button" id="record" class="visually-hidden">Record</button>
    </div>

    <%= for entry <- @uploads.notes.entries do %><div class="upload-entry">
      <progress value={entry.progress} class="upload-entry__progress" id={"#{entry.ref}-progress"} max="100">
      <%= entry.progress %>%
      </progress>
      <p><%= entry.client_name %></p>
    </div><% end %>

    <%= for path <- @uploaded_files do %><div class="upload-entry">
    <audio controls src={path}>
      Your browser does not support the
      <code>audio</code> element.
    </audio>
    <p><code>audio.src = <%= path %></code></p>
    </div><% end %>

    <form id="upload-form" "method="POST" action="#" id="basic-uploads-form" phx-change="validate" phx-submit="submit">
      <%= live_file_input @uploads.notes, class: "visually-hidden" %>
    </form>
    """
  end
end
