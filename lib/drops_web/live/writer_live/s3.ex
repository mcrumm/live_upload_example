defmodule DropsWeb.WriterLive.S3 do
  @moduledoc """
  Demonstrates S3 stream-to-stream via the `Phoenix.LiveView.UploadWriter` behaviour.
  """
  use DropsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-2 grid-rows-1 gap-4">
      <section>
        <h2 class="text-2xl">S3 Uploads</h2>

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
          <h2 class="text-2xl">Pending Upload</h2>

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

      <section>
        <h2 class="text-2xl">Last Upload</h2>
        <pre :if={@last_upload}><code><%= inspect @last_upload, pretty: true %></code></pre>
        <p :if={is_nil(@last_upload)}>Upload a file to inspect the result.</p>
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

    socket =
      case results do
        [] -> socket
        [upload] -> assign(socket, :last_upload, upload)
      end

    {:noreply, socket}
  end

  # MiB
  @mebibyte 1_048_576

  @chunk_size 5 * @mebibyte
  @max_file_size 1000 * @mebibyte

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:last_upload, nil)
     |> allow_upload(:files,
       accept: :any,
       chunk_size: @chunk_size,
       chunk_timeout: 30_000,
       max_file_size: @max_file_size,
       writer: &upload_writer/3
     )}
  end

  defp upload_writer(_name, %Phoenix.LiveView.UploadEntry{} = entry, _socket) do
    bucket = Application.fetch_env!(:drops, :s3_bucket)
    {S3UploadWriter, bucket: bucket, content_type: entry.client_type, path_prefix: "drops/"}
  end
end
