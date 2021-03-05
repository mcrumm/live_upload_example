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
    ~L"""
    <form id="<% @id %>-upload-form"
          class="upload-component"
          action="#"
          phx-change="validate"
          phx-drop-target="<%= @uploads.upload_component_file.ref %>"
          phx-submit="save"
          phx-target="<%= @myself %>">

      <%= live_file_input @uploads.upload_component_file %>

      <div class="preview"><%= for entry <- @uploads.upload_component_file.entries do %>
        <%= live_img_preview entry %>
      <% end %></div>

      <button type="submit">Upload</button>
    </form>
    """
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _, socket) do
    [filename] =
      consume_uploaded_entries(socket, :upload_component_file, fn %{path: path}, _entry ->
        dest = Path.join(Drops.uploads_priv_dir(), Path.basename(path))
        File.cp!(path, dest)
        Path.basename(dest)
      end)

    upload_path = Routes.static_path(socket, "/uploads/#{filename}")

    send(self(), {__MODULE__, socket.assigns.id, upload_path})

    {:noreply, socket}
  end
end
