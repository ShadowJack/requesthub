defmodule Requestbin.Test.Factory do
  use ExMachina.Ecto, repo: Requestbin.Repo

  alias Requestbin.Users.User
  alias Requestbin.Bins.{Bin, Request, RequestType}

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

  def request_factory(attrs) do
    bin = Map.get_lazy(attrs, :bin, fn -> insert(:bin) end)
    verb = Map.get(attrs, :verb, "POST")
    content_type = Map.get(attrs, :content_type, "application/json")
    body = Map.get(attrs, :body, "")
    parsed_body = Map.get(attrs, :parsed_body)
    query = Map.get(attrs, :query)
    type = 
      case Map.get(attrs, :type) do
        nil -> nil
        type_name -> RequestType.get_type_id_by_name(type_name)
      end

    request = %Request{
      bin: bin,
      bin_id: bin.id, 
      verb: verb,
      headers: %{"content-type" => content_type},
      body: body,
      parsed_body: parsed_body,
      query: query,
      type: type, 
      port: 4000,
      ip_address: %Postgrex.INET{address: {127, 0, 0, 1}}
    }
  end
end
