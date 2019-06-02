defmodule RequestbinWeb.LiveReloadSocket do
  @moduledoc """
  A custom socket for Phoenix live reload.
  It's required to use a Jason encoder for transport layer.
  """
  use Phoenix.Socket, log: false

  ## Channels
  channel "phoenix:live_reload", Phoenix.LiveReloader.Channel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    check_origin: false,
    serializer: [
      {Phoenix.Transports.WebSocketSerializer, "~> 1.0.0"},
      {RequestbinWeb.JasonChannelSerializer, "~> 2.0.0"}
    ]

  def connect(_params, socket), do: {:ok, socket}

  def id(_socket), do: nil
end
