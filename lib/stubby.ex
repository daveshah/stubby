defmodule Stubby do
  @moduledoc """
  Documentation for Stubby.
  """

  @doc """
  """
  # TODO: take erlang version into consideration
  def collect_callbacks(module) do
    module.module_info[:attributes]
    |> Keyword.take([:behaviour])
    |> Keyword.values
    |> List.flatten
    |> Enum.reduce([], fn(b, acc) ->
      acc ++ b.behaviour_info(:callbacks) end)
  end

  def function_signatature(0), do: "()"
  def function_signatature(arity) do
    sig =
      Range.new(1,arity)
      |> Enum.reduce("", fn(a,acc) -> acc <> "arg#{a}," end)
      |> String.trim_trailing(",")

    "(#{sig})"
  end

  defmacro __using__(_args) do
    #TODO: generate (arg1, arg2,... ) based on arity
    # generate ets calls based on arity
    """
    def foo(a,b) do
      IO.puts a
      IO.puts b
    end

    def bar() do
      IO.puts "bar"
    end
    """
    |> Code.string_to_quoted!
  end
end
