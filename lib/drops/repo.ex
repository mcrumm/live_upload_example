defmodule Drops.Repo do
  use Ecto.Repo,
    otp_app: :drops,
    adapter: Ecto.Adapters.Postgres
end
