defmodule ExPlainTest do
  use ExUnit.Case
  doctest ExPlain

  test "greets the world" do
    assert ExPlain.hello() == :world
  end
end
