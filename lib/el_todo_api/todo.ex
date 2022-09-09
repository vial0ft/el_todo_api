defmodule ElTodoApi.Todo do
  defstruct [:id, :text, :created_at, :updated_at, :expare_at, done: false]

  import DateTime, only: [utc_now: 0, from_iso8601: 1, compare: 2]
  alias ElTodoApi.Todo

  @spec new :: %ElTodoApi.Todo{
          created_at: DateTime.t(),
          done: false,
          expare_at: nil,
          id: nil,
          text: nil,
          updated_at: nil
        }
  def new(), do: %Todo{created_at: utc_now()}

  def new(params) when is_map(params), do: from_params(params, new())

  def update(todo, update_params) when is_map(update_params) do
    %Todo{from_params(update_params, todo) | updated_at: utc_now()}
  end

  def destruct(todo), do: Map.from_struct(todo)

  def is_expared?(_todo = %Todo{expare_at: nil}), do: false

  def is_expared?(_todo = %Todo{expare_at: date}) do
    case compare(date, utc_now()) do
      :gt -> false
      _ -> true
    end
  end

  defp from_params(params, seed) when is_map(params) do
    with text <- fetch(params, "text"),
         expare_at <- fetch(params, "expare_at"),
         done <- fetch(params, "done", seed.done) do
      expare_at =
        if(not is_nil(expare_at)) do
          if is_bitstring(expare_at) do
            {:ok, iso_date_time, _} = from_iso8601(expare_at)
            iso_date_time
          else
            expare_at
          end
        else
          expare_at
        end

      %Todo{
        seed
        | text: text,
          expare_at: expare_at,
          done: done
      }
    end
  end

  defp fetch(params, key, default \\ nil) when is_map(params) do
    v = Map.get(params, key)

    if is_nil(v) do
      Map.get(params, String.to_atom(key), default)
    else
      v
    end
  end
end
