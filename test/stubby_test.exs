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
    use Stubby, for: [StubbyTest.FakeBehaviour, StubbyTest.FakeBehaviour2]
  end

  describe "collect_callbacks/1" do
    test "returning all the callbacks within a module" do
      callbacks = Stubby.collect_callbacks([FakeBehaviour, FakeBehaviour2])

      assert [fake_function: 2, fake_function: 1,
              fake_function2: 2, fake_function2: 1] = callbacks
    end
  end

  describe "function_signature/1" do
    test "returns a signature string with a matching arity" do
      assert Stubby.function_signatature(0) == "()"
      assert Stubby.function_signatature(1) == "(arg1)"
      assert Stubby.function_signatature(3) == "(arg1,arg2,arg3)"
    end
  end

  describe "function_gen/1" do
    test "returns a function as a string" do
      assert Stubby.function_gen({:foo, 2}) ==
      """
        def foo(arg1,arg2) do
          :ets.lookup(__MODULE__, :foo)[:foo].(arg1,arg2)
        end
      """
    end
  end

  test "function generation" do
    FakeStub.setup

    FakeStub.stub(:fake_function, fn _ -> "works!" end)

    assert FakeStub.fake_function("anything") == "works!"
  end
end
