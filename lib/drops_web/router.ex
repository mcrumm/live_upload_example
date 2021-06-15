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

    live_session :default do
      live "/", PageLive, :index
      live "/uploader", UploaderLive.Demo, :index
      live "/uploader/start", UploaderLive.Demo, :start
      live "/uploader/done", UploaderLive.Demo, :done
      live "/uploader/brb", UploaderLive.Demo, :continue

      live "/uploads/basic", BasicUploadsLive, :index
      live "/uploads/auto", UploadsLive.Auto, :index
      live "/uploads/element", UploadsLive.Element, :index
      live "/uploads/component", ComponentUploadsLive, :index
      live "/uploads/multi", MultiInputUploadsLive, :index
      live "/uploads/external/auto", ExternalLive.Auto, :index
    end
  end
end
