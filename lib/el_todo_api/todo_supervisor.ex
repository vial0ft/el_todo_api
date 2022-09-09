defmodule ElTodoApi.TodoSupervisor do
  use Supervisor
  require Logger

  def todos_dyn_supervisor, do: :todos_dyn_supervisor
  def todos_registry, do: :todos_registry

  def start_link(init_arg) do
    Logger.info("start super")
    Supervisor.start_link(__MODULE__, init_arg, name: ElTodoApi.TodoSupervisor)
  end

  def init(_init_arg) do
    Logger.info("Super Init")

    children = [
      {Registry, keys: :unique, name: todos_registry()},
      %{
        id: DynamicSupervisor,
        start:
          {DynamicSupervisor, :start_link,
           [[strategy: :one_for_one, name: todos_dyn_supervisor()]]}
      }
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  @spec get_or_create_process(any) :: :ignore | {:error, any} | {:ok, any} | {:ok, pid, any}
  def get_or_create_process(account_id) do
    case Registry.lookup(todos_registry(), account_id) do
      [pid, _] ->
        {:ok, pid}

      _ ->
        case create_process(account_id) do
          {:ok, _pid} = p -> p
          {:error, {:already_started, pid}} -> {:ok, pid}
          err -> err
        end
    end
  end

  def process_name(account_id), do: {:via, Registry, {todos_registry(), account_id}}

  defp create_process(account_id) do
    child = %{
      id: account_id,
      start: {ElTodoApi.TodosRepo, :start_link, [account_id]}
    }

    DynamicSupervisor.start_child(todos_dyn_supervisor(), child)
  end
end
