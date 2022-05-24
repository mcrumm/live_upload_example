defmodule DropsWeb.IssuesLive.ExternalUploadSingleEntry do
  use DropsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Partial External Upload Bug (Issue 2037)</h1>

    <p>Steps to reproduce:</p>
    <ol>
      <li>Select a file.</li>
      <li>Click the Save button.</li>
      <li>Observe an entry error.</li>
      <li>Select a file again.</li>
      <li>Observe both a validate and save event sent from the client.</li>
      <li>Observe the save event causes the LiveView process to raise.</li>
    </ol>

    <p>Note: These uploads are simulated and always error.</p>

    <section class="row upload-demo">
      <section class="column">
        <h2>Upload</h2>

        <p>You may add up to <%= @uploads.avatar.max_entries %> avatar at a time.</p>

        <%= for error <- upload_errors(@uploads.avatar) do %>
          <p class="alert alert-danger"><%= upload_error_to_string(error) %></p>
        <% end %>

        <form id="issue-2037" phx-change="validate" phx-submit="save">
          <%= live_file_input(@uploads.avatar) %>
          <%= submit("Save") %>
        </form>

        <section
          class="pending-uploads"
          phx-drop-target={@uploads.avatar.ref}
          style="min-height: 100%;"
        >
          <h3>Pending Uploads (<%= length(@uploads.avatar.entries) %>)</h3>

          <%= for entry <- @uploads.avatar.entries do %>
            <%= for error <- upload_errors(@uploads.avatar, entry) do %>
              <p class="alert alert-danger"><%= upload_error_to_string(error) %></p>
            <% end %>
            <pre class="upload-entry"><code><%= inspect(entry, pretty: true) %></code></pre>
          <% end %>
        </section>
      </section>

      <section class="column">
        <h2>UUIDs (<%= length(@uploaded_files) %>)</h2>

        <output form="external-auto-form" for={@uploads.avatar.ref}>
          <%= for uuid <- @uploaded_files do %>
            <p><%= uuid %></p>
          <% end %>
        </output>
      </section>
    </section>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar,
       accept: :any,
       max_entries: 1,
       external: &presigned_upload/2
     )}
  end

  defp presigned_upload(entry, socket) do
    meta = %{
      uploader: "ImmediatelyError",
      name: entry.client_name,
      ref: entry.ref,
      uuid: entry.uuid
    }

    {:ok, meta, socket}
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
end
