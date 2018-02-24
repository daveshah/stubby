defmodule StubbyTest do
  use ExUnit.Case
  doctest Stubby

  test "greets the world" do
    assert Stubby.hello() == :world
  end
end
