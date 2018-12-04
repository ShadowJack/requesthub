defmodule Requestbin.Bins.RequestType do
  @moduledoc """
  Detect the type of request: multipart, urlencoded, etc.
  """

  @values [:other, :urlencoded, :multipart, :json, :xml]
  
  @doc """
  Find out the type of request from the conneciton
  """
  @spec detect_type(Plug.Conn.t) :: integer
  def detect_type(%Plug.Conn{req_headers: headers}) do
    case Enum.find(headers, fn {name, _} -> name == "content-type" end) do
      {_, content_type} -> detect_type_from_content_type(content_type)
      nil -> get_type_id_by_name(:other)
    end
  end
  def detect_type(_), do: get_type_id_by_name(:other)

  @doc """
  Convert id into atom
  """
  @spec get_type_name_by_id(integer) :: atom | nil
  def get_type_name_by_id(id) do
    Enum.at(@values, id)
  end

  @doc """
  Convert atom into id
  """
  @spec get_type_id_by_name(atom) :: integer | nil
  def get_type_id_by_name(name) do
    Enum.find_index(@values, fn x -> x == name end)
  end

  ## Private
  #
  @spec detect_type_from_content_type(String.t) :: integer
  defp detect_type_from_content_type(content_type) do
    atom = cond do
      content_type =~ "x-www-form-urlencoded" -> :urlencoded
      content_type =~ "multipart" -> :multipart
      content_type =~ "application/json" -> :json
      content_type =~ "application/xml" -> :xml
      :otherwise -> :other
    end
    get_type_id_by_name(atom)
  end
end
