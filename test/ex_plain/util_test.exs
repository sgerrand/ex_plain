defmodule ExPlain.UtilTest do
  use ExUnit.Case, async: true

  import ExPlain.Util

  describe "camelize_keys/1" do
    test "converts atom keys to camelCase strings" do
      assert %{"fooBar" => 1} = camelize_keys(%{foo_bar: 1})
    end

    test "converts string keys to camelCase" do
      assert %{"fooBar" => 1} = camelize_keys(%{"foo_bar" => 1})
    end

    test "recurses into nested maps" do
      assert %{"outer" => %{"innerKey" => true}} =
               camelize_keys(%{outer: %{inner_key: true}})
    end

    test "recurses into lists" do
      assert [%{"myKey" => 1}, %{"myKey" => 2}] =
               camelize_keys([%{my_key: 1}, %{my_key: 2}])
    end

    test "passes through scalar values unchanged" do
      assert "hello" = camelize_keys("hello")
      assert 42 = camelize_keys(42)
      assert true = camelize_keys(true)
      assert nil == camelize_keys(nil)
    end
  end

  describe "build_pagination_vars/1" do
    test "builds empty map when no pagination opts given" do
      assert %{} = build_pagination_vars([])
    end

    test "includes all four pagination keys when provided" do
      vars = build_pagination_vars(first: 10, after: "c1", last: 5, before: "c2")
      assert %{first: 10, after: "c1", last: 5, before: "c2"} = vars
    end
  end

  describe "put_if_set/3" do
    test "does not set key when value is nil" do
      assert %{} = put_if_set(%{}, :key, nil)
    end

    test "sets key when value is non-nil" do
      assert %{key: "val"} = put_if_set(%{}, :key, "val")
    end
  end
end
