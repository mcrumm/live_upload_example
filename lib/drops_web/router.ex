defmodule DropsWeb.Router do
  use DropsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DropsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DropsWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/uploads/basic", BasicUploadsLive, :index
    live "/uploads/component", ComponentUploadsLive, :index
    live "/uploads/multi", MultiInputUploadsLive, :index
  end
end
