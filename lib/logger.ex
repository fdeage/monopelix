defmodule Monopoly.Logger do
  def print(msg) when is_binary(msg) or is_integer(msg) or is_atom(msg) do
    if should_log?() do
      IO.puts(msg)
    end
  end

  def print(msg) do
    if should_log?() do
      IO.inspect(msg)
      IO.puts("\n")
    end
  end

  def print(msg, nil) when is_binary(msg) or is_integer(msg) or is_atom(msg) do
    if should_log?() do
      IO.puts(msg)
    end
  end

  def print(msg1, msg2)
      when (is_binary(msg1) or is_integer(msg1) or is_atom(msg1)) and
             (is_binary(msg2) or is_integer(msg2) or is_atom(msg2)) do
    if should_log?() do
      IO.puts("#{msg1}: #{msg2}")
    end
  end

  def print(msg1, msg2) do
    if should_log?() do
      IO.inspect(msg1)
      IO.inspect(msg2)
      IO.puts("\n")
    end
  end

  defp should_log? do
    log_level = Application.get_env(:monopoly, :log_level)
    log_level === :basic or log_level === :all
  end
end
