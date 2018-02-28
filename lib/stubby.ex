defmodule Stubby do
  @moduledoc """
  Documentation for Stubby.
  """

  def collect_callbacks(behaviours) do
    behaviours
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

  def function_gen({name, arity}) do
    """
      def #{name}#{function_signatature(arity)} do
        :ets.lookup(__MODULE__, :#{name})[:#{name}].#{function_signatature(arity)}
      end
    """
  end

  def setup_funcs() do
    """
      def setup() do
        :ets.new(__MODULE__, [:set, :private, :named_table])
      end

      def stub(function_name, function) when is_atom(function_name) do
        :ets.insert(__MODULE__, {function_name, function})
      end
    """
  end

  def define_functions_for(behaviours) do
    behaviours
    |> Stubby.collect_callbacks
    |> Enum.reduce(setup_funcs(),
        fn (c, acc) -> acc <> Stubby.function_gen(c) end)
    |> String.trim
  end

  defmacro __using__(args) do
    {[for: behaviours], _} =
      Macro.to_string(args)
      |> Code.eval_string

    Stubby.define_functions_for(behaviours)
    |> Code.string_to_quoted!
  end
end
