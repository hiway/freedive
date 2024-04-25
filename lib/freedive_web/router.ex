defmodule FreediveWeb.Router do
  use FreediveWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FreediveWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FreediveWeb do
    pipe_through :browser

    live "/", HomeLive

    live "/system/preferences", SystemPreferencesLive
    live "/system/secrets", SystemSecretsLive
    live "/system/security", SystemSecurityLive
    live "/system/backups", SystemBackupsLive
    live "/system/updates", SystemUpdatesLive

    live "/cluster/nodes", ClusterNodesLive

    live "/network/local", NetworkLocalLive
    live "/network/private", NetworkPrivateLive
    live "/network/public", NetworkPublicLive
    live "/network/domains", NetworkDomainsLive
    live "/network/endpoints", NetworkEndpointsLive

    live "/data/local", DataLocalLive
    live "/data/remote", DataRemoteLive
    live "/data/share", DataShareLive
    live "/data/sync", DataSyncLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", FreediveWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:freedive, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FreediveWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
