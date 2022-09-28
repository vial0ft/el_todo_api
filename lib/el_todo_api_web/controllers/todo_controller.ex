defmodule ElTodoApiWeb.TodoController do
  require Logger

  import Plug.Conn.Status, only: [code: 1]

  use ElTodoApiWeb, :controller
  use PhoenixSwagger
  alias ElTodoApi.TodoProvider

    def swagger_definitions do
      ElTodoApiWeb.SwaggerInfo.schema
    end

  swagger_path :fetch_all do
    get("/api")
    produces "application/json"
    description("List of todos")
    response(code(:ok), "", Schema.ref(:Todos))
    response(code(:not_found), "Not Found")
  end

  def fetch_all(conn, _params) do
    get_user(conn)
    |> TodoProvider.get_all()
    |> case do
      {:ok, result} ->
        json(conn, result)

      _ ->
        conn
        |> put_status(:not_found)
    end
  end

  swagger_path :get_by_id do
    get "/api/{id}"
    produces "application/json"
    ElTodoApiWeb.SwaggerInfo.id_todo_param
    description("Get todo by id")
    response(code(:ok), "", Schema.ref(:TodoView))
    response(code(:not_found), "Not Found")
  end

  def get_by_id(conn, %{"id" => todo_id}) do
    get_user(conn)
    |> TodoProvider.get_by_id(todo_id)
    |> case  do
      {:ok, result} -> json(conn, result)
      _ ->
        conn
        |> put_status(:not_found)
    end
  end

  swagger_path :create do
    post "/api"
    consumes "application/json"
    produces "application/json"
    ElTodoApiWeb.SwaggerInfo.body_todo_params
    description("Create new todo item")
    response(code(:ok), "", Schema.ref(:TodoParams))
    response(code(:not_found), "Not Found")
  end

  def create(conn, param) do
    get_user(conn)
    |> TodoProvider.upsert(param)
    |> case do
      {:ok, result} -> json(conn, result)
      err -> json(conn, err)
    end
  end

  swagger_path :update do
    put "/api/{id}"
    consumes "application/json"
    produces "application/json"
    ElTodoApiWeb.SwaggerInfo.id_todo_param
    ElTodoApiWeb.SwaggerInfo.body_todo_params
    description("Update existed todo item")
    response(code(:ok), "", Schema.ref(:TodoParams))
    response(code(:not_found), "item with id {id} not found")
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


  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/{id}"
    produces "application/json"
    ElTodoApiWeb.SwaggerInfo.id_todo_param
    description("Delete existed todo item")
    response(code(:ok), "Return id of deleted todo item")
    response(code(:not_found), "item with id {id} not found")
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
