defmodule ExPlainTest do
  use ExUnit.Case

  test "new/1 builds a client with required api_key" do
    client = ExPlain.new(api_key: "test_key")
    assert %ExPlain.Client{} = client
  end

  test "new/1 raises if api_key is missing" do
    assert_raise KeyError, fn -> ExPlain.new([]) end
  end
end
