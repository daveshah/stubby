defmodule Stubby do
  @moduledoc """
  Documentation for Stubby.
  """

  @doc """
  """
  #TODO: take erlang version into consideration
  # :application.which_applications can give me the info I need.
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
    # TODO: setup_all with context...
    """
      def setup() do
        :ets.new(__MODULE__, [:set, :private, :named_table])
      end

      # TODO: stub with the context
      def setup(context) when is_atom(context) do
        :ets.new(context, [:set, :private, :named_table])
      end

      def stub(function_name, function) when is_atom(function_name) do
        :ets.insert(__MODULE__, {function_name, function})
      end
    """
  end

  def gen_func(behaviours) do
    behaviours
    |> Stubby.collect_callbacks
    |> Enum.reduce(setup_funcs(),
        fn (c, acc) -> acc <> Stubby.function_gen(c) end)
    |> String.trim
  end

  defmacro __using__(args) do
    {[for: b], _} = Macro.to_string(args) |> Code.eval_string
    Stubby.gen_func(b) |> Code.string_to_quoted!
  end
end
