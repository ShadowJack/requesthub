# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Requestbin.Repo.insert!(%Requestbin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
alias Requestbin.{Repo, SeedIds, Bins.Bin, Bins.Request}

defmodule SeedHelpers do
  def localhost() do
    %Postgrex.INET{address: {127, 0, 0, 1}}
  end
end

# insert a test bin
Repo.insert!(%Bin{
  id: SeedIds.bin_id,
  name: "Test bin"
})

# insert requests
# GET
Repo.insert!(%Request{
  id: SeedIds.get_id,
  bin_id: SeedIds.bin_id,
  verb: "GET",
  query: "a=123&b=321&q=this%20is%20a%20question",
  headers: %{"host" => "localhost:4000", "accept" => "text/html", "accept-language" => "ru"},
  port: 54127,
  type: 0
})
# OPTIONS
Repo.insert!(%Request{
  id: SeedIds.options_id,
  bin_id: SeedIds.bin_id,
  verb: "OPTIONS",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl"},
  ip_address: SeedHelpers.localhost(),
  port: 57824,
  type: 0
})
# HEAD
Repo.insert!(%Request{
  id: SeedIds.head_id,
  bin_id: SeedIds.bin_id,
  verb: "HEAD",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl"},
  ip_address: SeedHelpers.localhost(),
  port: 55824,
  type: 0
})
# DELETE
Repo.insert!(%Request{
  id: SeedIds.delete_id,
  bin_id: SeedIds.bin_id,
  verb: "DELETE",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl"},
  ip_address: SeedHelpers.localhost(),
  port: 55555,
  type: 0
})
# PUT
Repo.insert!(%Request{
  id: SeedIds.put_id,
  bin_id: SeedIds.bin_id,
  verb: "PUT",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl", "content-type" => "application/json", "content-length" => "37"},
  body: "{\"test\":123, \"data\":{\"arr\": [1,2,3]}}",
  ip_address: SeedHelpers.localhost(),
  port: 23455,
  type: 3
})
# PATCH
Repo.insert!(%Request{
  id: SeedIds.patch_id,
  bin_id: SeedIds.bin_id,
  verb: "PATCH",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl", "content-type" => "application/json", "content-length" => "37"},
  body: "{\"test\":111, \"data\":{\"arr\": [3,2,1]}}",
  ip_address: SeedHelpers.localhost(),
  port: 23455,
  type: 3
})
# POST application/json
Repo.insert!(%Request{
  id: SeedIds.post_json_id,
  bin_id: SeedIds.bin_id,
  verb: "POST",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl", "content-type" => "application/json", "content-length" => "37"},
  body: "{\"test\":222, \"data\":{\"arr\": [3,2,2]}}",
  ip_address: SeedHelpers.localhost(),
  port: 23411,
  type: 3
})
# POST www-formurlencoded
Repo.insert!(%Request{
  id: SeedIds.post_urlencoded_id,
  bin_id: SeedIds.bin_id,
  verb: "POST",
  query: "a=1&test=false",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl", "content-type" => "application/x-www-form-urlencoded", "content-length" => "16"},
  body: "a[]=1&b=32&a[]=1",
  ip_address: SeedHelpers.localhost(),
  port: 23401,
  type: 1
})
# POST multipart/form-data
Repo.insert!(%Request{
  id: SeedIds.post_form_data_id,
  bin_id: SeedIds.bin_id,
  verb: "POST",
  headers: %{"host" => "localhost:4000", "accept" => "*/*", "user-agent" => "curl", "content-type" => "multipart/form-data, boundary=AaB03x", "content-length" => "154"},
  body: "--AaB03x
content-disposition: form-data; name=\"field1\"

$field1
--AaB03x
content-disposition: form-data; name=\"field2\"

some value of the field2
--AaB03x",
  ip_address: SeedHelpers.localhost(),
  port: 23401,
  type: 1
})
