defmodule ElTodoApiWeb.SwaggerInfo do
  @moduledoc "Common parameter declarations for phoenix swagger"

  use PhoenixSwagger

  alias PhoenixSwagger.Path
  import PhoenixSwagger.Path


  def schema do
    %{
      TodoView: swagger_schema do
        title "TodoView"
        PhoenixSwagger.Schema.description "Todo item"
        properties do
          id :number, "Unique identifier", required: true
          text :string, "Text of todo"
          done :boolean, "Flag of compleation (false by default)"
          expare_at :date_time, "Date of exparation (ISO 8601 format)"
          created_at :date_time, "Date of creation (ISO 8601 format) (auto-generate)", required: true
          updated_at :string, "Date of last update todo's info (ISO 8601 format)"
        end
        example %{
          id: 123,
          text: "To buy 3 tomatos",
          done: false,
          expare_at: DateTime.utc_now() |> DateTime.add(1000, :second) |> DateTime.to_string,
          created_at: DateTime.utc_now() |> DateTime.to_string,
          updated_at:  DateTime.utc_now() |> DateTime.to_string
        }
      end,
      TodoParams: swagger_schema do
        title "TodoParams"
        PhoenixSwagger.Schema.description "Todo item"
        properties do
          text :string, "Text of todo"
          done :boolean, "Flag of compleation (false by default)"
          expare_at :date_time, "Date of exparation (ISO 8601 format)"
        end
        example %{
          text: "To buy 3 tomatos",
          done: false,
          expare_at: DateTime.utc_now() |> DateTime.add(1000, :second) |> DateTime.to_string
        }
      end,
      Todos: swagger_schema do
        PhoenixSwagger.Schema.description "A collection of Todo"
        type :array
        items Schema.ref(:TodoView)
      end
    }
  end

  def authorization(path = %Path.PathObject{}) do
    path |> parameter("Authorization", :header, :string, "OAuth2 access token", required: true)
  end

  def id_todo_param(path = %Path.PathObject{}) do
    path
    |> parameter(:id, :query, :number, "Todo uniq identifier", required: true)
  end

  def body_todo_params(path = %Path.PathObject{}) do
    path
    |> parameter("", :body, Schema.ref(:TodoParams), "Todo params", required: true)
  end


  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "El Todo App"
      },
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          name: "Authorization",
          description: "API Token must be provided via `Authorization: Bearer ` header",
          in: "header"
        }
      },
    }
  end
end
