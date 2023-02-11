defmodule DropsWeb.Uploads do
  @moduledoc """
  Conveniences for working with uploads.
  """
  alias Phoenix.LiveView

  @doc """
  Returns the directory where uploads are stored.
  """
  def uploads_dir do
    Application.app_dir(:drops, ["priv", "static", "uploads"])
  end

  @doc """
  Consumes the given upload entries and copies them to the uploads directory.
  """
  def consume_entries(%LiveView.Socket{} = socket, name)
      when is_atom(name) or is_binary(name) do
    LiveView.consume_uploaded_entries(socket, name, &__MODULE__.consume_entry/2)
  end

  @doc """
  Consumes the uploaded entries for the given `name` and adds them to the end
  of the list at the given `key` in assigns.
  """
  def consume_append_entries(socket, name, key) do
    consume_and_update(socket, name, key, &(&2 ++ &1))
  end

  @doc """
  Consumes the uploaded entries for the given `name` and adds them to the front
  of the list at the given `key` in assigns.
  """
  def consume_prepend_entries(socket, name, key) do
    consume_and_update(socket, name, key, &(&1 ++ &2))
  end

  @doc """
  Consumes the uploaded entries for the given `name` and replaces the given `key`
  in assigns with the new entries.

  This function respects the `:max_entries` option of the LiveView UploadConfig and
  will update the assigns with the first item in the list when the config has
  `max_entries: 1`.
  """
  def consume_replace_entries(socket, name, key) do
    case socket.assigns.uploads do
      %{^name => %Phoenix.LiveView.UploadConfig{max_entries: 1}} ->
        consume_and_update(socket, name, key, fn [x | _], _ -> x end)

      %{^name => %Phoenix.LiveView.UploadConfig{}} ->
        consume_and_update(socket, name, key, & &1)

      _ ->
        raise "no upload named #{name} found"
    end
  end

  @doc """
  Consumes the uploaded entries for the given `name` and supplies them to an update
  callback for the given `key` in assigns.
  """
  def consume_and_update(%LiveView.Socket{} = socket, name, key, update)
      when (is_atom(name) or is_binary(name)) and is_atom(key) and
             (is_function(update, 2) or is_function(update, 3)) do
    paths = consume_entries(socket, name)
    update_after_consume(socket, key, paths, update)
  end

  @doc """
  Consumes a single upload entry.

  This is useful mostly for consuming auto-uploaded entries.
  """
  def consume_on_done(%LiveView.Socket{} = socket, %LiveView.UploadEntry{} = entry) do
    if entry.done? do
      LiveView.consume_uploaded_entry(socket, entry, fn meta ->
        consume_entry(meta, entry)
      end)
    end
  end

  @doc """
  Consume the entry and updates the socket via the given `update callback.
  """
  def update_on_done(
        %LiveView.Socket{} = socket,
        %LiveView.UploadEntry{} = entry,
        key,
        update \\ &[&1 | &2]
      )
      when is_atom(key) and (is_function(update, 2) or is_function(update, 3)) do
    if path = consume_on_done(socket, entry) do
      update_after_consume(socket, key, path, update)
    else
      socket
    end
  end

  defp update_after_consume(socket, key, path, update) when is_function(update, 2) do
    Phoenix.Component.update(socket, key, &update.(path, &1))
  end

  defp update_after_consume(socket, key, path, update) when is_function(update, 3) do
    Phoenix.Component.update(socket, key, &update.(path, &1, &2))
  end

  @doc false
  def consume_entry(%{path: path}, _) do
    base = Path.basename(path)
    dest = Path.join(uploads_dir(), base)

    # todo: postpone and send cancel if copying fails
    File.cp!(path, dest)

    {:ok, upload_path(base)}
  end

  def consume_entry(%{uploader: _} = meta, _entry) do
    # External upload
    {:ok, meta}
  end

  @doc """
  Returns the static path to the given `file`.
  """
  def upload_path(file) do
    DropsWeb.Router.Helpers.static_path(DropsWeb.Endpoint, "/uploads/#{file}")
  end
end
