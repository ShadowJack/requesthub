defmodule Requestbin.Test.Factory do
  use ExMachina.Ecto, repo: Requestbin.Repo

  alias Requestbin.Users.User
  alias Requestbin.Bins.Bin

  def user_factory() do
    %User{
      email: sequence(:email, &"email-#{&1}@mail.com"),
      first_name: "John",
      last_name: "Doe",
      password_hash: "abcdefg"
    }
  end

  def bin_factory() do
    %Bin{
      name: sequence(:bin_name, &"Bin #{&1}")
    }
  end

  def private_bin_factory() do
    struct!(
      bin_factory(),
      %{
        users: [build(:user)]
      }
    )
  end
end
