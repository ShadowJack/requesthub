defmodule RequestbinWeb.BinView do
  use RequestbinWeb, :view

  alias Requestbin.Bins.Bin

  @doc """
  Formats bin title
  """
  @spec format_bin_title(Bin.t) :: String.t
  def format_bin_title(%Bin{id: id, name: nil}) do
    shorten_middle(id, 18)
  end
  def format_bin_title(%Bin{name: name}) do
    name
  end
end
