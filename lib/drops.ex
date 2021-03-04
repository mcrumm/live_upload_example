defmodule Drops do
  @moduledoc """
  Drops keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Returns a path in the `priv` dir to store uploads.
  """
  def uploads_priv_dir do
    Path.join([:code.priv_dir(:drops), "static", "uploads"])
  end
end
