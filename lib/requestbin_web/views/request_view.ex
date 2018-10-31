defmodule RequestbinWeb.RequestView do
  use RequestbinWeb, :view

  @doc """
  Shorten the `input` string if it excedes the `length`.
  The ellipsis is added if the string was shortened.
  """
  @spec shorten(String.t, integer) :: String.t
  def shorten(input, length) do
    if String.length(input) > length do
      String.slice(input, 0, length) <> "…"
    else
      input
    end
  end

  @doc """
  Shorten the `input` string if it excedes the `length`.
  The beginning of the stirng is truncated and the ellipsis 
  is added if the string was shortened.
  """
  @spec shorten(String.t, integer) :: String.t
  def shorten_beginning(input, length) do
    if String.length(input) > length do
      "…" <> String.slice(input, -length..-1)
    else
      input
    end
  end
end
