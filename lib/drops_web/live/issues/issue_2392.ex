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
        </form>
      </section>

      <section class="column">
        <section
          class="pending-uploads"
          phx-drop-target={@uploads.avatar.ref}
          style="min-height: 100%;"
        >
          <h2>Preview</h2>

          <%= for entry <- @uploads.avatar.entries do %>
            <%= for error <- upload_errors(@uploads.avatar, entry) do %>
              <p class="alert alert-danger"><%= upload_error_to_string(error) %></p>
            <% end %>
            <.live_img_preview entry={entry} />
            <button type="button" class="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
              Cancel Upload
            </button>
          <% end %>
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
      consume_uploaded_entries(socket, :avatar, fn params, _entry ->
        IO.inspect(params, label: :upload_params)
        {:ok, params}
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
     )}
  end
end
