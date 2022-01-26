defmodule LittleWeb.Router do
  use LittleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LittleWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LittleWeb do
    pipe_through :browser

    live "/", GameLive
    live "/board", BoardLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LittleWeb do
  #   pipe_through :api
  # end
end
