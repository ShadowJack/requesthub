defmodule RequestbinWeb.Views.Utils do
  @moduledoc """
  Useful helpers to be used in views and templates.
  """

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
  @spec shorten_beginning(String.t, integer) :: String.t
  def shorten_beginning(input, length) do
    if String.length(input) > length do
      "…" <> String.slice(input, -length..-1)
    else
      input
    end
  end

  @doc """
  Shorten the `input` string if it excedes the `length`.
  Middle of the stirng is truncated and the ellipsis 
  is added if the string was shortened.
  """
  @spec shorten_middle(String.t, integer) :: String.t
  def shorten_middle(input, length) do
    if String.length(input) > length do
      part_size = div(length, 2) - 1
      String.slice(input, 0, part_size) <> "…" <> String.slice(input, -part_size..-1) 
    else
      input
    end
  end
end
