defmodule Requestbin.CleanupExpiredBinsTest do
  use Requestbin.DataCase

  alias Requestbin.Test.Factory
  alias Requestbin.Tasks.CleanupExpiredBins
  alias Requestbin.Bins

  defp build_bin(days_old, private \\ false, attrs \\ []) do
    days_ago = DateTime.utc_now() |> DateTime.add(-60 * 60 * 24 * days_old)
    factory_name = if private, do: :private_bin, else: :bin
    Factory.insert(factory_name, Keyword.put(attrs, :inserted_at, days_ago))
  end

  test "public bins are deleted after two days" do
    bin = build_bin(4)

    CleanupExpiredBins.delete_public_bins()

    assert Bins.get_bin(bin.id) == nil
  end

  test "private bins are deleted after a week" do
    bin = build_bin(8, true)

    CleanupExpiredBins.delete_private_bins()

    assert Bins.get_bin(bin.id) == nil
  end

  test "private bins are not deleted earlier than a week" do
    bin = build_bin(4, true)

    CleanupExpiredBins.delete_private_bins()

    assert Bins.get_bin(bin.id) != nil
  end
end
