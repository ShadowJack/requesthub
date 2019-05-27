defmodule Requestbin.Tasks.CleanupExpiredBins do
  @moduledoc """
  A task to delete old bins
  """

  import Ecto.Query
  alias Ecto.Multi
  alias Requestbin.Repo
  alias Requestbin.Bins.{Bin, Request}
  alias Requestbin.Users.UserBin

  @public_bins_lifetime_in_seconds 60 * 60 * 24 * 2
  @private_bins_lifetime_in_seconds 60 * 60 * 24 * 7

  @spec run() :: :ok
  def run() do
    delete_public_bins()
    delete_private_bins()
  end

  @spec delete_public_bins() :: :ok
  def delete_public_bins() do
    bin_ids = 
      old_bins_query(@public_bins_lifetime_in_seconds)
      |> public_filter()
      |> Repo.all()
    
    # delete the bins with associated requests
    Multi.new()
    |> Multi.delete_all(:requests, (from r in Request, where: r.bin_id in ^bin_ids))
    |> Multi.delete_all(:bins, (from b in Bin, where: b.id in ^bin_ids))
    |> Repo.transaction()
  end

  @spec delete_private_bins() :: :ok
  def delete_private_bins() do
    bin_ids = 
      old_bins_query(@private_bins_lifetime_in_seconds) 
      |> private_filter()
      |> Repo.all()

    # delete the bins with associated requests and users_requests associations
    Multi.new()
    |> Multi.delete_all(:requests, (from r in Request, where: r.bin_id in ^bin_ids))
    |> Multi.delete_all(:user_bins, (from ub in UserBin, where: ub.bin_id in ^bin_ids ))
    |> Multi.delete_all(:bins, (from b in Bin, where: b.id in ^bin_ids))
    |> Repo.transaction()
  end

  # base query for old bins selection
  defp old_bins_query(lifetime) do
    expiration_date = DateTime.utc_now() |> DateTime.add(-lifetime)
    
    from b in Bin, 
      where: b.inserted_at < ^expiration_date and b.id != ^Requestbin.SeedIds.bin_id,
      select: b.id
  end

  # take only private bins
  defp private_filter(query) do
    from b in query,
      join: ub in UserBin,
      on: ub.bin_id == b.id
  end

  # take only public bins
  defp public_filter(query) do
    from b in query,
      left_join: ub in UserBin,
      on: ub.bin_id == b.id,
      where: is_nil(ub.user_id)
  end
end
