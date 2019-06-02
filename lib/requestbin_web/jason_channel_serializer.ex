defmodule RequestbinWeb.JasonChannelSerializer do
  @moduledoc """
  A custom json serializer to be used in Phoenix channels.
  Is taken from https://gist.github.com/michalmuskala/d5fabcd26be2befdfb72b72e0b0f2797
  """
  @behaviour Phoenix.Transports.Serializer

  alias Phoenix.Socket.{Reply, Message, Broadcast}

  @doc """
  Translates a `Phoenix.Socket.Broadcast` into a `Phoenix.Socket.Message`.
  """
  def fastlane!(%Broadcast{topic: topic, event: event, payload: payload}) do
    data = [nil, nil, topic, event, payload]
    {:socket_push, :text, Jason.encode_to_iodata!(data)}
  end

  @doc """
  Encodes a `Phoenix.Socket.Message` struct to JSON string.
  """
  def encode!(%Reply{
    join_ref: join_ref,
    ref: ref,
    topic: topic,
    status: status,
    payload: payload
  }) do
    data = [join_ref, ref, topic, "phx_reply", %{status: status, response: payload}]
    {:socket_push, :text, Jason.encode_to_iodata!(data)}
  end
  def encode!(%Message{
    join_ref: join_ref,
    ref: ref,
    topic: topic,
    event: event,
    payload: payload
  }) do
    data = [join_ref, ref, topic, event, payload]
    {:socket_push, :text, Jason.encode_to_iodata!(data)}
  end

  @doc """
  Decodes JSON String into `Phoenix.Socket.Message` struct.
  """
  def decode!(raw_msg, _opts) do
    [join_ref, ref, topic, event, payload | _] = Jason.decode!(raw_msg)
    %Phoenix.Socket.Message{
      topic: topic,
      event: event,
      payload: payload,
      ref: ref,
      join_ref: join_ref
    }
  end
end
