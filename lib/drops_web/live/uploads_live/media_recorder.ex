defmodule DropsWeb.UploadsLive.MediaRecorder do
  use DropsWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:media_error, nil)
      |> assign(:media_ready, false)
      |> assign(:record_action, :record)
      |> assign(:uploaded_files, [])
      |> allow_upload(:clips,
        accept: ~w(audio/*),
        max_size: 100_000_000,
        auto_upload: true,
        progress: &handle_progress/3
      )

    {:ok, socket}
  end

  # with auto_upload: true we can consume files here
  defp handle_progress(:clips, entry, socket) do
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
  def handle_event("media-recorder:client:error", %{"reason" => reason}, socket) do
    media_error =
      case reason do
        "access_denied" ->
          "You denied access to the microphone so this demo will not work."

        "not_supported" ->
          "Sorry, your browser doesn't support the MediaRecorder API, so this demo will not work."

        _ ->
          "An unknown error has occurred"
      end

    {:noreply, assign(socket, :media_error, media_error)}
  end

  @impl true
  def handle_event("use-mic", _, socket) do
    {:noreply, push_event(socket, "media-recorder:server:request", %{"name" => "clips"})}
  end

  @impl true
  def handle_event("media-recorder:client:ready", _, socket) do
    {:noreply, assign(socket, :media_ready, true)}
  end

  @impl true
  # no-op but required for live_file_input validation
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("record", _, socket) do
    {:noreply,
     socket
     |> assign(:record_action, :stop)
     |> push_event("media-recorder:server:start", %{"name" => "clips"})}
  end

  @impl true
  def handle_event("stop", _, socket) do
    {:noreply,
     socket
     |> assign(:record_action, :record)
     |> push_event("media-recorder:server:stop", %{"name" => "clips"})}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :clips, ref)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h2>MediaRecorder Demo</h2>
    <p>Within this demonstration you can record an audio sample and will be automatically uploaded to the server.</p>
    <p>Thanks to <a href="https://twitter.com/philnash">@philnash</a> for the <a href="https://www.twilio.com/blog/mediastream-recording-api">example that inspired this demo</a>.</p>

    <section class="row upload-demo">
      <section class="column">
        <%= if @media_error do %><p class="alert alert-danger"><%= @media_error %></p><% end %>
        <div id="media-recorder-demo" class="controls" phx-hook="MediaRecorderDemo">
          <button type="button" phx-click="use-mic" id="mic" phx-disable-with="Please wait..." class={if @media_ready, do: "visually-hidden"}>Use Mic</button>
          <button type="button" phx-click={@record_action} id="record" class={unless @media_ready, do: "visually-hidden"}><%= @record_action %></button>
        </div>
        <form id="upload-form" action="#" id="basic-uploads-form" phx-change="validate" phx-submit="submit">
          <%= live_file_input @uploads.clips, class: "visually-hidden" %>
        </form>
      </section>
      <section class="column">
        <h2>Recordings</h2>
        <%= for entry <- @uploads.clips.entries do %><div class="upload-entry">
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
      </section>
    </section>
    """
  end
end
