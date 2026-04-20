defmodule ExPlain.DateTimeTest do
  use ExUnit.Case, async: true

  alias ExPlain.DateTime

  describe "from_map/1" do
    test "returns nil for nil" do
      assert nil == DateTime.from_map(nil)
    end

    test "decodes with iso8601 and unix timestamp" do
      assert %DateTime{iso8601: "2024-01-01T00:00:00Z", unix_timestamp: "1704067200"} =
               DateTime.from_map(%{
                 "iso8601" => "2024-01-01T00:00:00Z",
                 "unixTimestamp" => "1704067200"
               })
    end

    test "decodes with iso8601 only" do
      assert %DateTime{iso8601: "2024-01-01T00:00:00Z", unix_timestamp: nil} =
               DateTime.from_map(%{"iso8601" => "2024-01-01T00:00:00Z"})
    end
  end
end
