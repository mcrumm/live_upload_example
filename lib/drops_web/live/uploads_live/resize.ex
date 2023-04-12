defmodule DropsWeb.UploadsLive.Resize do
  use DropsWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h1>Resize Example</h1>
    <p>This example illustrates how to resize an image before uploading it to the web server.</p>
    <!-- Users select files with this file input. -->
    <input type="file" id="resize-target" phx-hook="ResizeInput" data-upload-target="images" />

    <form phx-change="change" phx-submit="submit">
      <!-- The live file input is hidden because users will not interact with it directly. -->
      <.live_file_input upload={@uploads.images} style="display:none;" />
      <button type="submit">Upload</button>
    </form>

    <section class="row upload-demo">
      <section class="column">
        <h3>Pending Uploads</h3>

        <div :for={entry <- @uploads.images.entries} class="upload-entry" id={"entry-#{entry.ref}"}>
          <% # render in-flight progress using the reactive `entry.progress` %>
          <DropsWeb.Uploads.progress entry={entry} />

          <div class="upload-entry__details">
            <% # <.live_img_preview> uses an internal hook to render a client-side image preview %>
            <.live_img_preview entry={entry} />

            <% # review the handle_event("cancel-upload") callback in the LiveView %>
            <a
              href="#"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              class="upload-entry__cancel"
            >
              &times;
            </a>
          </div>

          <% # upload_errors/2 returns error atoms per upload entry %>
          <p :for={error <- upload_errors(@uploads.images, entry)} class="alert alert-danger">
            <%= upload_error_to_string(error) %>
          </p>
        </div>
      </section>

      <section class="column">
        <h3>Uploaded Images</h3>
        <DropsWeb.Uploads.figure_group paths={@uploaded_files} />
      </section>
    </section>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("change", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, DropsWeb.Uploads.consume_prepend_entries(socket, :images, :uploaded_files)}
  end

  @impl Phoenix.LiveView
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:images, accept: ~w(image/*), max_entries: 25)}
  end
end
