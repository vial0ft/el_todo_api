defmodule ElTodoApi.TodosRepo do
  use GenServer
  require Logger

  import ElTodoApi.TodoSupervisor, only: [process_name: 1]
  alias ElTodoApi.Todo

  def start_link(account_id) do
    GenServer.start_link(__MODULE__, account_id, name: process_name(account_id))
  end

  def init(account_id) do
    table_name = :ets.new(String.to_atom(account_id), [:named_table, :ordered_set, :protected])

    {:ok,
     %{
       account_id: account_id,
       table_name: table_name,
       max_id: 1
     }}
  end

  def handle_call(:fetch_all, _from, state) do
    todo_list =
      get_table_name(state)
      |> :ets.tab2list()
      |> Enum.map(fn {_, todo} -> todo end)

    {:reply, {:ok, todo_list}, state}
  end

  def handle_call({:get_by_id, todo_id}, _from, state) do
    result =
      get_table_name(state)
      |> get_by_id(todo_id)

    {:reply, result, state}
  end

  def handle_call({:delete, todo_id}, _from, state) do
    get_table_name(state)
    |> :ets.delete(todo_id)

    {:reply, {:ok, todo_id}, state}
  end

  def handle_call({:upsert, todo_params}, _from, state) when is_map(todo_params) do
    upsert(todo_params, Map.get(todo_params, "id"), state)
  end

  def handle_call({:upsert, todo_params}, _from, state) do
    Logger.info("update #{inspect(todo_params)}")
    name = get_table_name(state)

    case get_by_id(name, todo_params["id"]) do
      {:not_found, _todo_id} = not_found ->
        {:reply, not_found, state}

      {:ok, existed_todo} ->
        Logger.info("before #{inspect(existed_todo)} and param #{inspect(todo_params)}")
        updated_todo = Todo.update(existed_todo, todo_params)
        Logger.info("after #{inspect(updated_todo)}")
        :ets.insert(name, {updated_todo.id, updated_todo})
        {:reply, {:ok, updated_todo}, state}
    end
  end

  def handle_call(msg, from, state) do
    Logger.info("Unknown msg #{inspect(msg)} from #{inspect(from)}")
    {:reply, :do_nothing, state}
  end

  defp upsert(todo_params, nil, state) do
    Logger.info("new #{inspect(todo_params)}")

    with name <- get_table_name(state),
         id <- get_max_id(state) + 1,
         new_todo <- %Todo{Todo.new(todo_params) | id: id} do
      Logger.info("save #{inspect(new_todo)}")
      :ets.insert_new(name, {new_todo.id, new_todo})
      {:reply, {:ok, new_todo}, %{state | max_id: id}}
    else
      err -> {:reply, {:error, err}, state}
    end
  end

  defp upsert(todo_params, todo_id, state) do
    Logger.info("update #{inspect(todo_params)}")
    name = get_table_name(state)
    {id, _} = Integer.parse(todo_id)

    case get_by_id(name, id) do
      {:not_found, _todo_id} = not_found ->
        {:reply, not_found, state}

      {:ok, existed_todo} ->
        Logger.info("before #{inspect(existed_todo)} and param #{inspect(todo_params)}")
        updated_todo = Todo.update(existed_todo, todo_params)
        Logger.info("after #{inspect(updated_todo)}")
        :ets.insert(name, {updated_todo.id, updated_todo})
        {:reply, {:ok, updated_todo}, state}
    end
  end

  def handle_info(:info, state) do
    Logger.info("info #{inspect(state)}")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("get info msg: #{inspect(msg)}. Do nothing")
    {:noreply, state}
  end

  defp get_by_id(table_name, todo_id) do
    case :ets.lookup(table_name, todo_id) do
      [{^todo_id, todo}] -> {:ok, todo}
      _ -> {:not_found, todo_id}
    end
  end

  defp get_table_name(%{:table_name => name}), do: name
  defp get_max_id(%{:max_id => max_id}), do: max_id
end
