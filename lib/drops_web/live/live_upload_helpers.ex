defmodule DropsWeb.LiveUploadHelpers do
  alias Phoenix.LiveView.UploadConfig

  @doc """
  A work-around to return the "too many files" error.
  """
  def upload_error(%UploadConfig{} = config) do
    for {ref, error} <- config.errors, ref == config.ref, reduce: nil do
      _ -> error
    end
  end

  @doc """
  Returns an error message for an upload error.

  See [`upload_errors/2`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Helpers.html#upload_errors/2).
  """
  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
