defmodule ElTodoApi.Guardian do

  require Logger

  use Guardian, otp_app: :el_todo_api
  # alias ElAuth.Accounts

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(claims) do
    {:ok, "user_#{claims["sub"]}"}
  end
end
