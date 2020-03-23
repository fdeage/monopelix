defmodule Monopoly.Logger do
  @log false

  def print(msg) when is_binary(msg) or is_integer(msg) or is_atom(msg) do
    if @log do
      IO.puts(msg)
    end
  end

  def print(msg) do
    if @log do
      IO.inspect(msg)
    end
  end

  def print(msg, nil) when is_binary(msg) or is_integer(msg) or is_atom(msg) do
    if @log do
      IO.puts(msg)
    end
  end

  def print(msg1, msg2)
      when (is_binary(msg1) or is_integer(msg1) or is_atom(msg1)) and
             (is_binary(msg2) or is_integer(msg2) or is_atom(msg2)) do
    if @log do
      IO.puts("#{msg1}: #{msg2}")
    end
  end

  def print(msg1, msg2) do
    if @log do
      IO.inspect(msg1)
      IO.inspect(msg2)
    end
  end
end
