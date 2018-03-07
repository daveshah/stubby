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

  defmodule TestModule do
    def some_function, do: :ok
    def some_function(arg), do: {:ok, arg}
    def some_other_function, do: :ok
  end

  defmodule TestModuleStub do
    use Stubby, module: StubbyTest.TestModule
  end

  describe "collect_callbacks/1" do
    test "returning all the callbacks within a module" do
      callbacks = Stubby.collect_callbacks([FakeBehaviour, FakeBehaviour2])

      assert {:fake_function, 1} in callbacks
      assert {:fake_function, 1} in callbacks
      assert {:fake_function2, 1} in callbacks
      assert {:fake_function2, 2} in callbacks
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
          try do
            :ets.lookup(unique_name(), :foo)[:foo].(arg1,arg2)
          rescue
            ArgumentError -> raise Stubby.Error
          end
        end
      """
    end
  end

  describe "behaviour based function generation" do
    setup do
      FakeStub.setup
    end

    test "stubbing functions" do
      FakeStub.stub(:fake_function, fn _ -> "works!" end)

      assert FakeStub.fake_function("anything") == "works!"
    end
  end

  describe "module based function generation" do
    setup do
      TestModuleStub.setup
      TestModuleStub.stub(:some_function, fn (thing) -> "#{thing} works!" end)
    end

    test "stubbing functions" do
      assert TestModuleStub.some_function("anything") == "anything works!"
    end
  end

  describe "error messages" do
    test "when stubs haven't been setup" do
      assert_raise(Stubby.Error, "Has setup/0 been called before stubbing?",
        fn ->
          FakeStub.fake_function("setup hasn't been called")
        end)
    end
  end
end
