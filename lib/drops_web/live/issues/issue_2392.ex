defmodule DropsWeb.IssuesLive.Issue2392 do
  use DropsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <h2>Drag and drop, max_entries: 1 stops accepting input</h2>
    <p>
      <.link href="https://github.com/phoenixframework/phoenix_live_view/issues/2392" target="_blank">
        Issue 2392
      </.link>
    </p>

    <p>Steps to reproduce:</p>
    <ol>
      <li>Select a file from the input.</li>
      <li>Try to drag and drop more files.</li>
      <li>Observe the drag and drop behavior stops responding.</li>
    </ol>

    <section class="row upload-demo">
      <section class="column">
        <h2>Upload</h2>

        <p>You may add up to <%= @uploads.avatar.max_entries %> avatar at a time.</p>

        <%= for error <- upload_errors(@uploads.avatar) do %>
          <p class="alert alert-danger"><%= upload_error_to_string(error) %></p>
        <% end %>

        <form
          id="issue-2392"
          phx-change="validate"
          phx-submit="save"
          phx-drop-target={@uploads.avatar.ref}
          style="border:1px dashed #639; padding:1rem"
        >
          <label for={@uploads.avatar.ref}>Drag and drop or select files:</label>
          <.live_file_input upload={@uploads.avatar} />
          <input type="submit" value="Submit" />
        </form>
      </section>

      <section class="column">
        <section class="pending-uploads">
          <h2>Preview</h2>

          <div :for={entry <- @uploads.avatar.entries}>
            <p :for={error <- upload_errors(@uploads.avatar, entry)} class="alert alert-danger">
              <%= upload_error_to_string(error) %>
            </p>
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
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        # Drops.copy_entry_to_uploads(path)
        dest = Path.join(Drops.uploads_priv_dir(), Path.basename(path))
        File.cp!(path, dest)
        static_path = Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
        {:ok, static_path}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
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
       max_entries: 1
     ), temporary_assigns: [uploaded_files: []]}
  end
end