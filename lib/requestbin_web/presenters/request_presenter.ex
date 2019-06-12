defmodule RequestbinWeb.Presenters.RequestPresenter do
  @moduledoc """
  A decorator of the `Requestbin.Bins.Request` that
  adds some fields required only in the view
  """

  alias Requestbin.Bins.Request

  defstruct request: nil, is_collapsed: true
  @type t :: %__MODULE__{
    request: Request.t,
    is_collapsed: boolean
  }

  @doc """
  Build a presenter from a model
  """
  @spec build(Request.t) :: RequestPresenter.t
  def build(req) do
    %__MODULE__{request: req}
  end
end
