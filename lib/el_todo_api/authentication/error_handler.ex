defmodule ElTodoApi.Guardian.ErrorHandler do
 import Plug.Conn

 @behaviour Guardian.Plug.ErrorHandler

 @impl Guardian.Plug.ErrorHandler
 @spec auth_error(Plug.Conn.t(), {any, any}, any) :: Plug.Conn.t()
 def auth_error(conn, {type, reason}, _opts) do
  body = Jason.encode!(%{error: to_string(type), reason: to_string(reason)})

  conn
  |> put_resp_content_type("application/json")
  |> send_resp(401, body)
 end
end
