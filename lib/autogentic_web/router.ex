defmodule AutogenticWeb.Router do
  use AutogenticWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AutogenticWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AutogenticWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/agents", AgentListLive, :index
    live "/agents/:id", AgentDetailLive, :show
    live "/reasoning", ReasoningLive, :index
    live "/learning", LearningLive, :index
    live "/demo", DemoLive, :index
  end

  scope "/api", AutogenticWeb do
    pipe_through :api

    post "/agents/:id/message", AgentController, :send_message
    get "/agents/:id/state", AgentController, :get_state
    get "/system/health", SystemController, :health
    get "/reasoning/sessions", ReasoningController, :list_sessions
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:autogentic, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AutogenticWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
