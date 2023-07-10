defmodule DropsWeb.WriterLive.Echo do
  @moduledoc """
  Demonstrates custom upload writers using a modified EchoWriter example from the LiveView docs.

  This writer logs metadata about each chunk of data it receives as it arrives on the server.
  """
  use DropsWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Advanced: UploadWriter behaviour</h1>
    <p>
      Using a custom <code>:writer</code>
      for server-side uploads. The writer on this LiveView logs metadata about each chunk as it arrives on the server.
    </p>

    <div class="row grid grid-cols-2 grid-rows-1 gap-4">
      <section class="column">
        <form
          id="upload-form"
          phx-submit="save"
          phx-change="validate"
          phx-drop-target={@uploads.files.ref}
        >
          <div class="my-3">
            <label for={@uploads.files.ref}>Upload or drop files here:</label>
            <.live_file_input
              upload={@uploads.files}
              class={[
                "relative m-0 block w-full min-w-0 flex-auto",
                "rounded border border-solid border-neutral-300",
                "bg-clip-padding px-3 py-[0.32rem] text-base font-normal text-neutral-700"
              ]}
            />
          </div>

          <button type="submit" phx-disable-with="Uploading...">Upload</button>
        </form>

        <section :if={Enum.any?(@uploads.files.entries)}>
          <h3 class="text-xl">Pending Uploads</h3>

          <div :for={entry <- @uploads.files.entries}>
            <DropsWeb.Uploads.progress entry={entry} />
            <div>
              <span><%= entry.client_name %></span>
              <a
                href="#"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                class="upload-entry__cancel"
              >
                &times;
              </a>
            </div>

            <p :for={error <- upload_errors(@uploads.files, entry)} class="alert alert-danger">
              <%= upload_error_to_string(error) %>
            </p>
          </div>
        </section>
      </section>

      <section class="column">
        <h2 class="text-2xl">Uploaded Files</h2>
        <p :if={Enum.empty?(@uploaded_files)}>Upload files to inspect the results.</p>
        <pre :for={file <- @uploaded_files}><code><%= inspect file, pretty: true %></code></pre>
      </section>
    </div>
    """
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _, socket) do
    results = consume_uploaded_entries(socket, :files, fn upload, _entry -> {:ok, upload} end)

    {:noreply, update(socket, :uploaded_files, fn files -> results ++ files end)}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:files,
       accept: :any,
       chunk_size: 256 * 1_024,
       max_file_size: 100 * 1_024 * 1_024,
       max_entries: 10,
       writer: fn name, entry, _socket ->
         {EchoWriter, level: :debug, upload: name, entry: entry}
       end
     )}
  end
end
