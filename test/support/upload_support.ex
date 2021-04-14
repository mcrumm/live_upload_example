defmodule DropsWeb.UploadSupport do
  @moduledoc """
  Helpers for working with file uploads under test.
  """

  @doc """
  Returns a map of upload attrs for a path and content type.

  ## Examples

      iex(1)> [:code.priv_dir(:drops), "static", "images", "phoenix.png"] \
      iex(1)> |> Path.join() \
      iex(1)> |> build_upload("image/png")
      %{name: "phoenix.png", type: "image/png", size: 13900, ...}
  """
  def build_upload(path, content_type \\ "application/octet-stream") do
    upload = %{name: Path.basename(path), type: content_type}

    %{mtime: mtime, size: size} = File.stat!(path)

    last_modified =
      mtime
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_unix()

    upload
    |> Map.put(:size, size)
    |> Map.put(:last_modified, last_modified)
    |> Map.put(:content, File.read!(path))
  end
end
