defmodule ExPlain.TiersTest do
  use ExUnit.Case, async: true

  alias ExPlain.Tiers.Tier

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "list/2" do
    test "returns paginated tiers" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "tiers" => %{
              "edges" => [%{"node" => tier_fixture()}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%Tier{}]}} = ExPlain.Tiers.list(stub_client(__MODULE__))
    end
  end

  describe "get_by_id/2" do
    test "returns tier when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"tier" => tier_fixture()}})
      end)

      assert {:ok, %Tier{id: "tier_01"}} =
               ExPlain.Tiers.get_by_id(stub_client(__MODULE__), "tier_01")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"tier" => nil}})
      end)

      assert {:ok, nil} = ExPlain.Tiers.get_by_id(stub_client(__MODULE__), "tier_unknown")
    end
  end

  describe "add_members/2" do
    test "returns memberships list" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "addMembersToTier" => %{
              "memberships" => [%{"id" => "m_01"}],
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, [%{"id" => "m_01"}]} =
               ExPlain.Tiers.add_members(stub_client(__MODULE__), %{
                 tier_identifier: %{tier_id: "tier_01"},
                 member_identifiers: [%{tenant_identifier: %{external_id: "ext_01"}}]
               })
    end

    test "returns error on mutation failure" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "addMembersToTier" => %{"memberships" => nil, "error" => mutation_error_fixture()}
          }
        })
      end)

      assert {:error, %ExPlain.Error{type: :mutation_error}} =
               ExPlain.Tiers.add_members(stub_client(__MODULE__), %{
                 tier_identifier: %{tier_id: "tier_01"},
                 member_identifiers: [%{tenant_identifier: %{external_id: "ext_01"}}]
               })
    end
  end

  describe "remove_members/2" do
    test "returns :removed on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"removeMembersFromTier" => %{"error" => nil}}
        })
      end)

      assert {:ok, :removed} =
               ExPlain.Tiers.remove_members(stub_client(__MODULE__), %{
                 tier_identifier: %{tier_id: "tier_01"},
                 member_identifiers: [%{tenant_identifier: %{external_id: "ext_01"}}]
               })
    end

    test "returns error on mutation failure" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "removeMembersFromTier" => %{"error" => mutation_error_fixture()}
          }
        })
      end)

      assert {:error, %ExPlain.Error{type: :mutation_error}} =
               ExPlain.Tiers.remove_members(stub_client(__MODULE__), %{
                 tier_identifier: %{tier_id: "tier_01"},
                 member_identifiers: [%{tenant_identifier: %{external_id: "ext_01"}}]
               })
    end
  end

  # ---------------------------------------------------------------------------

  defp mutation_error_fixture do
    %{"message" => "Invalid.", "type" => "VALIDATION", "code" => "validation", "fields" => []}
  end

  defp tier_fixture do
    %{
      "id" => "tier_01",
      "name" => "Enterprise",
      "externalId" => nil,
      "defaultThreadPriority" => 1,
      "createdAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "createdBy" => nil,
      "updatedAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "updatedBy" => nil
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
