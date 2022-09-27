defmodule ElTodoApiWeb.Router do
  use ElTodoApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ElTodoApiWeb do
    pipe_through :api
    resources "/", TodoController, except: [:new, :edit]
  end

  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :el_todo_api,
      swagger_file: "swagger.json"
  end

  def swagger_info do
    ElTodoApiWeb.SwaggerInfo.swagger_info()
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: ElTodoApiWeb.Telemetry
    end
  end
end
