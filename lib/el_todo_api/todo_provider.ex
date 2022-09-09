defmodule ElTodoApi.TodoProvider do
  require Logger
  alias ElTodoApi.TodoSupervisor
  alias ElTodoApi.Todo

  def get_all({account_id}) do
    case send_msg(account_id, :fetch_all) do
      {:ok, todo_list} -> {:ok, Enum.map(todo_list, &Todo.destruct/1)}
      other -> other
    end
  end

  def get_by_id({account_id}, todo_id) do
    {id, _} = Integer.parse(todo_id)
    case send_msg(account_id, {:get_by_id, id}) do
      {:ok, todo} -> {:ok, Todo.destruct(todo)}
      other -> other
    end
  end

  def upsert({account_id}, todo_params) do
    case send_msg(account_id, {:upsert, todo_params}) do
      {:ok, todo} -> {:ok, Todo.destruct(todo)}
      other -> other
    end
  end

  def delete({account_id}, todo_id) do
    {id, _} = Integer.parse(todo_id)
    case send_msg(account_id, {:delete, id}) do
      {:ok, todo} -> {:ok, Todo.destruct(todo)}
      other -> other
    end
  end

  defp send_msg(account_id, msg) do
    Logger.info("send #{inspect(msg)} for #{account_id}")

    with {:ok, repo_pid} <- TodoSupervisor.get_or_create_process(account_id),
         {:ok, _result} = r <- GenServer.call(repo_pid, msg) do
      r
    else
      err ->
        Logger.error("Fail '#{inspect(msg)}' for #{account_id}: #{inspect(err)}")
        err
    end
  end
end
