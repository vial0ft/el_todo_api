defmodule ElTodoApiWeb.TodoController do
  require Logger

  use ElTodoApiWeb, :controller
  alias ElTodoApi.TodoProvider

  # req_headers
  def index(conn, _params) do
    get_user(conn)
    |> TodoProvider.get_all()
    |> case do
      {:ok, result} ->
        json(conn, result)

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{})
    end
  end

  def show(conn, %{"id" => todo_id}) do
    get_user(conn)
    |> TodoProvider.get_by_id(todo_id)
    |> case  do
      {:ok, result} -> json(conn, result)
      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{})
    end
  end

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, param) do
    get_user(conn)
    |> TodoProvider.upsert(param)
    |> case do
      {:ok, result} -> json(conn, result)
      err -> json(conn, err)
    end
  end

  def update(conn, param) do
    get_user(conn)
    |> TodoProvider.upsert(param)
    |> case do
      {:ok, result} ->
        json(conn, result)

      {:not_found, id} ->
        conn
        |> put_status(:not_found)
        |> json(err_msg(:not_found, "item with id #{id} not found"))

      {:error, why} ->
        json(conn, err_msg(:unknown, inspect(why)))
    end
  end

  def delete(conn, %{"id" => todo_id}) do
    get_user(conn)
    |> TodoProvider.delete(todo_id)
    |> case  do
      {:ok, result} -> json(conn, result)
      other -> json(conn, other)
    end
  end

  defp err_msg(type, msg) do
    %{error: Atom.to_string(type), msg: msg}
  end

  def get_user(_conn) do
    {"admin"}
  end
end
