defmodule Requestbin.Users.Guardian do
  @moduledoc """
  An implementation of guardian token
  """
  alias Requestbin.Users
  use Guardian, otp_app: :requestbin

  def subject_for_token(user, _) do
    {:ok, to_string(user.id)}
  end
  
  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
