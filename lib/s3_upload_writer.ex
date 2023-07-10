defmodule S3UploadWriter do
  @moduledoc """
  Streams uploads to an S3 bucket via `ExAws.S3`.

  Note that S3 multipart uploads require a `:chunk_size` of at least 5 MiB, so be sure to upload
  your [`allow_upload`](`Phoenix.LiveView.allow_upload/3`) configuration to account for this.

  ## Options

    * `:bucket` - Required. The name of the storage bucket.

    * `:path_prefix` - An optional string prefix to the generated object name.

    * `:config` - Optional config overrides to `ExAws.request/2`.

  All other options are passed directly to the CreateMultipartUpload request.
  Refer to `ExAws.S3.initiate_multipart_upload/3` for available options.

  """
  @behaviour Phoenix.LiveView.UploadWriter

  alias ExAws.S3

  @impl true
  def init(opts) do
    {bucket, opts} = Keyword.pop!(opts, :bucket)
    config = Keyword.get(opts, :config, [])

    path_prefix = Keyword.get(opts, :path_prefix, "")
    path = path_with_prefix(path_prefix)

    upload = S3.upload([], bucket, path, opts)

    with {:ok, upload} <- S3.Upload.initialize(upload, config) do
      {:ok, %{config: config, parts: [], part_number: 1, upload: upload}}
    end
  end

  @impl true
  def meta(state), do: state

  @impl true
  def write_chunk(data, state) do
    %{part_number: part_number} = state

    case S3.Upload.upload_chunk({data, part_number}, state.upload, state.config) do
      {^part_number, _etag} = part ->
        {:ok, %{state | parts: [part | state.parts], part_number: part_number + 1}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def close(state) do
    %{bucket: bucket, path: path, upload_id: upload_id} = state.upload

    request = S3.complete_multipart_upload(bucket, path, upload_id, Enum.reverse(state.parts))

    with {:ok, _} = ok <- ExAws.request(request, state.config) do
      # S3.Parsers.parse_complete_multipart_upload/1 is a no-op, so we need to
      # to invoke S3.Parsers.parse_upload/1 with a successful result
      {:ok, %{body: upload}} = S3.Parsers.parse_upload(ok)
      {:ok, upload}
    end
  end

  defp path_with_prefix(""), do: generate_object_name()
  defp path_with_prefix(prefix) when is_binary(prefix), do: prefix <> generate_object_name()

  defp path_with_prefix(other),
    do: raise(ArgumentError, "Expected a string for :path_prefix, got: #{inspect(other)}")

  defp generate_object_name(length \\ 16) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
