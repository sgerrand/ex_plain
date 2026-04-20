defmodule ExPlain.CustomerGroupsTest do
  use ExUnit.Case, async: true

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "list/2" do
    test "returns paginated customer groups" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "customerGroups" => %{
              "edges" => [%{"node" => group_fixture()}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%ExPlain.CustomerGroups.CustomerGroup{id: "cg_01"}]}} =
               ExPlain.CustomerGroups.list(stub_client(__MODULE__))
    end
  end

  describe "get_by_id/2" do
    test "returns group when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"customerGroup" => group_fixture()}})
      end)

      assert {:ok, %ExPlain.CustomerGroups.CustomerGroup{id: "cg_01"}} =
               ExPlain.CustomerGroups.get_by_id(stub_client(__MODULE__), "cg_01")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"customerGroup" => nil}})
      end)

      assert {:ok, nil} =
               ExPlain.CustomerGroups.get_by_id(stub_client(__MODULE__), "cg_unknown")
    end
  end

  # ---------------------------------------------------------------------------

  defp group_fixture do
    %{
      "id" => "cg_01",
      "key" => "enterprise",
      "name" => "Enterprise",
      "color" => "BLUE",
      "externalId" => nil,
      "createdAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "updatedAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"}
    }
  end

  defp page_info_fixture do
    %{
      "hasNextPage" => false,
      "hasPreviousPage" => false,
      "startCursor" => "c_start",
      "endCursor" => "c_end"
    }
  end
end
