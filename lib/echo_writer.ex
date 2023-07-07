defmodule EchoWriter do
  @moduledoc """
  An upload writer that logs the chunk sizes and tracks the total bytes sent by the client.

  ## Options

  * `:level` - Required. The level to log the messages.

  * `:upload` - Required. The name of the upload passed to the writer function.

  * `:entry` - Required. The upload entry passed to the writer function.

  ## Examples

      allow_upload(socket, :files, accept: :any, writer: fn name, entry, _socket ->
        {EchoUpload, level: :debug, upload: name, entry: entry}
      end)
  """
  @behaviour Phoenix.LiveView.UploadWriter
  require Logger

  @impl true
  def init(opts) do
    Keyword.validate!(opts, [:level, :upload, :entry])

    {:ok,
     %{
       total: 0,
       level: Keyword.fetch!(opts, :level),
       upload: Keyword.fetch!(opts, :upload),
       entry_meta: entry_meta(Keyword.fetch!(opts, :entry))
     }}
  end

  @impl true
  def meta(state), do: state.entry_meta

  @impl true
  def write_chunk(state, data) do
    size = byte_size(data)
    log_message(state, "received chunk of #{size} bytes")
    {:ok, %{state | total: state.total + size}}
  end

  @impl true
  def close(state) do
    log_message(state, "closing upload after #{state.total} bytes}")
    {:ok, state}
  end

  defp log_message(state, message) when is_binary(message) do
    Logger.log(
      state.level,
      "#{inspect(state.upload)} #{message}, entry_meta: #{inspect(state.entry_meta)}"
    )
  end

  defp entry_meta(%Phoenix.LiveView.UploadEntry{} = entry) do
    %{
      _ref: entry.ref,
      last_modified: entry.client_last_modified,
      name: entry.client_name,
      relative_path: entry.client_relative_path,
      size: entry.client_size,
      type: entry.client_type
    }
  end
end
