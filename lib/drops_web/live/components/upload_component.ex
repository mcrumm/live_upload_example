defmodule DropsWeb.UploadComponent do
  use DropsWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:upload_component_file, max_entries: 1, accept: ~w(image/*))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form
      id={"#{@id}-upload-form"}
      class="upload-component"
      action="#"
      phx-change="validate"
      phx-drop-target={@uploads.upload_component_file.ref}
      phx-submit="save"
      phx-target={@myself}
    >
      <.live_file_input upload={@uploads.upload_component_file} />
      <button type="submit">Upload</button>

      <section class="upload-entries">
        <h2>Preview</h2>
        <%= for entry <- @uploads.upload_component_file.entries do %>
          <div class="upload-entry__details">
            <% # <.live_img_preview> uses an internal hook to render a client-side image preview %>
            <.live_img_preview entry={entry} class="preview" />
            <% # review the handle_event("cancel") callback %>
            <a
              href="#"
              phx-click="cancel"
              phx-target={@myself}
              phx-value-ref={entry.ref}
              class="upload-entry__cancel"
            >
              &times;
            </a>
          </div>
        <% end %>
      </section>
    </form>
    """
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :upload_component_file, ref)}
  end

  def handle_event("save", _, socket) do
    case DropsWeb.Uploads.consume_entries(socket, :upload_component_file) do
      [] -> :ok
      [upload_path] -> hoist_upload(socket, upload_path)
    end

    {:noreply, socket}
  end

  defp hoist_upload(socket, upload_path) do
    send(self(), {__MODULE__, socket.assigns.id, upload_path})
    :ok
  end
end
