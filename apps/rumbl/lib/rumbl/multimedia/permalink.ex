defmodule Rumbl.Multimedia.Permalink do
  @behaviour Ecto.Type

  def type, do: :id

  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_) do
    :error
  end

  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def equal?(value1, value2) do
     with {:ok, integer1} <- cast(value1),
          {:ok, integer2} <- cast(value2) do
       integer1 == integer2
     else
       _ -> false
     end
   end

   def embed_as(_format) do
     :self
   end
end
