defmodule StubbyTest do
  use ExUnit.Case
  doctest Stubby

  defmodule FakeBehaviour2 do
    @callback fake_function2(term) :: {:ok, term} | {:error, String.t}
    @callback fake_function2(term, term) :: {:ok, term} | {:error, String.t}
  end

  defmodule FakeBehaviour do
    @callback fake_function(term) :: {:ok, term} | {:error, String.t}
    @callback fake_function(term, term) :: {:ok, term} | {:error, String.t}
  end

  defmodule FakeStub do
    @behaviour FakeBehaviour
    @behaviour FakeBehaviour2
    use Stubby
  end

  describe "collect_callbacks/1" do
    test "returning all the callbacks within a module" do
      assert Stubby.collect_callbacks(FakeStub) ==
             [fake_function: 2, fake_function: 1,
              fake_function2: 2, fake_function2: 1]
    end
  end
  describe "function_signature/1" do
    test "returns a signature string with a matching arity" do
      assert Stubby.function_signatature(0) == "()"
      assert Stubby.function_signatature(1) == "(arg1)"
      assert Stubby.function_signatature(3) == "(arg1,arg2,arg3)"
    end
  end


  # TODO: In Elixir version 1.3 callbacks can be found in module_info
  # in Elixir ??? they're in behaviour_info
  # NOTE: these are NOT public functions. These are
  # exports found from
  # Stubby.FakeBehaviour.behaviour_info(:callbacks)
  # :application.which_applications can give me the info I need...
  test "function generation" do
    #require IEx; IEx.pry
    FakeStub
  end
end
