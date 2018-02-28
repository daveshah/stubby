defmodule Stubby do
  @moduledoc """
  Usage

  Start by defining your Behaviour:

  ```
  defmodule Api do
    @callback all() :: {:ok, term} | {:error, String.t}
    @callback get(term) :: {:ok, term} | {:error, String.t}
    ...
  end
  ```

  Once a behaviour is defined, define your stub, using Stubby for one or more behaviours:
  ```
  defmodule StubApi do
    use Stubby, for: [Api, SomeOtherBehaviour]
  end
  ```

  In your tests, simply call your stubs generated setup/0 function:
  ```
  StubApi.setup
  ```

  Once setup/0 has been called, your stub will have a stub/2 function
  that takes in the function name you intend to stub as an atom and an anonymous function whose arity must match that of the stubbed function:

  ```
  StubApi.stub(:all, fn -> {:ok, "Awesome!"} end)
  ```

  """

  @doc false
  def collect_callbacks(behaviours) do
    behaviours
    |> Enum.reduce([], fn(b, acc) ->
      acc ++ b.behaviour_info(:callbacks) end)
  end

  @doc false
  def function_signatature(0), do: "()"
  @doc false
  def function_signatature(arity) do
    sig =
      Range.new(1,arity)
      |> Enum.reduce("", fn(a,acc) -> acc <> "arg#{a}," end)
      |> String.trim_trailing(",")

    "(#{sig})"
  end

  @doc false
  def function_gen({name, arity}) do
    """
      def #{name}#{function_signatature(arity)} do
        :ets.lookup(unique_name(), :#{name})[:#{name}].#{function_signatature(arity)}
      end
    """
  end

  @doc false
  def setup_funcs() do
    """

      def unique_name do
        inspect(__MODULE__) <> inspect(self()) |> String.to_atom
      end


      def setup do
        :ets.new(unique_name(), [:set, :private, :named_table])
      end

      def stub(function_name, function) when is_atom(function_name) do
        :ets.insert(unique_name(), {function_name, function})
      end
    """
  end

  @doc false
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
