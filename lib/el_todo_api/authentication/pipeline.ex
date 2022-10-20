defmodule ElTodoApi.Guardian.AuthPipeline do
@claims %{typ: "access"}

use Guardian.Plug.Pipeline,
    otp_app: :el_todo_api,
    module: ElTodoApi.Guardian,
    error_handler: ElTodoApi.Guardian.ErrorHandler


    plug(Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer")
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(Guardian.Plug.LoadResource, ensure: true)
end
