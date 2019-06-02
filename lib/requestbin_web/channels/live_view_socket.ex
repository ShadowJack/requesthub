defmodule RequestbinWeb.LiveViewSocket do
  @moduledoc """
  A custom socket for Phoenix LiveView.
  It's required to use a Jason encoder for transport layer.
  """
  use Phoenix.Socket

  ## Channels
  channel "lv:*", Phoenix.LiveView.Channel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    check_origin: false,
    serializer: [
      {Phoenix.Transports.WebSocketSerializer, "~> 1.0.0"},
      {RequestbinWeb.JasonChannelSerializer, "~> 2.0.0"}
    ]

  @doc """
  Connects the Phoenix.Socket for a LiveView client.
  """
  @impl Phoenix.Socket
  def connect(_params, %Phoenix.Socket{} = socket, _connect_info) do
    {:ok, socket}
  end

  @doc """
  Identifies the Phoenix.Socket for a LiveView client.
  """
  @impl Phoenix.Socket
  def id(_socket), do: nil
end
