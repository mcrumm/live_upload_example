defmodule DropsWeb.IssuesLive.Issue2271 do
  use DropsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <h2>max_entries: 1, auto_upload: true skips auto-upload every second entry</h2>
    <p>
      <.link href="https://github.com/phoenixframework/phoenix_live_view/issues/2271" target="_blank">
        Issue 2271
      </.link>
    </p>

    <p>Steps to reproduce:</p>
    <ol>
      <li>Select/drop a file. Observe the progress bar fill to 100%.</li>
      <li>Drop a second file to replace the first. Observe the progress bar stays 0.</li>
      <li>Repeat the progress and observe the progress updates for every other entry.</li>
      <li>Submit the form and observe that the consumed file is the last file selected.</li>
      <li><em>Note consuming the upload entry in the `:progress` handler avoids this issue.</em></li>
    </ol>

    <section class="row upload-demo">
      <section class="column">
        <h2>Upload</h2>

        <p>You may add up to <%= @uploads.avatar.max_entries %> avatar at a time.</p>

        <%= for error <- upload_errors(@uploads.avatar) do %>
          <p class="alert alert-danger"><%= upload_error_to_string(error) %></p>
        <% end %>

        <form
          id="issue-2271"
          phx-change="validate"
          phx-submit="save"
          phx-drop-target={@uploads.avatar.ref}
          style="border:1px dashed #639; padding:1rem"
        >
          <label for={@uploads.avatar.ref}>Drag and drop or select files:</label>
          <.live_file_input upload={@uploads.avatar} />
          <button type="submit" class="button">Submit</button>
        </form>
      </section>

      <section class="column">
        <section class="pending-uploads">
          <h2>Preview</h2>

          <div :for={entry <- @uploads.avatar.entries}>
            <p :for={error <- upload_errors(@uploads.avatar, entry)} class="alert alert-danger">
              <%= upload_error_to_string(error) %>
            </p>
            <progress value={entry.progress} max="100">
              <%= entry.progress %>%
            </progress>
            <.live_img_preview entry={entry} />
            <button type="button" class="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
              Cancel Upload
            </button>
          </div>
        </section>

        <section class="uploaded-files">
          <h2>Uploaded Files</h2>
          <p>These files are temporary&mdash; the list will be refreshed after each upload.</p>
          <figure :for={static_path <- @uploaded_files}>
            <img src={static_path} />
            <figcaption><%= static_path %></figcaption>
          </figure>
        </section>
      </section>
    </section>
    """
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, DropsWeb.Uploads.consume_append_entries(socket, :avatar, :uploaded_files)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar,
       accept: ~w(image/jpeg image/png),
       max_entries: 1,
       auto_upload: true
     ), temporary_assigns: [uploaded_files: []]}
  end
end
