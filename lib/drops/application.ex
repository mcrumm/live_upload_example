defmodule Drops.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Ensure the uploads path exists.
    DropsWeb.Uploads.uploads_dir() |> File.mkdir_p!()

    children = [
      # Start the Ecto repository
      Drops.Repo,
      # Start the Telemetry supervisor
      DropsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Drops.PubSub},
      # Start Finch
      {Finch, name: Drops.Finch},
      # Start the Endpoint (http/https)
      DropsWeb.Endpoint
      # Start a worker by calling: Drops.Worker.start_link(arg)
      # {Drops.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Drops.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DropsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
