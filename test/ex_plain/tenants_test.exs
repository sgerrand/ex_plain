defmodule ExPlain.TenantsTest do
  use ExUnit.Case, async: true

  alias ExPlain.Tenants.Tenant

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "list/2" do
    test "returns paginated tenants" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "tenants" => %{
              "edges" => [%{"node" => tenant_fixture()}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%Tenant{}]}} = ExPlain.Tenants.list(stub_client(__MODULE__))
    end
  end

  describe "get_by_id/2" do
    test "returns tenant when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"tenant" => tenant_fixture()}})
      end)

      assert {:ok, %Tenant{}} = ExPlain.Tenants.get_by_id(stub_client(__MODULE__), "ten_01")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"tenant" => nil}})
      end)

      assert {:ok, nil} = ExPlain.Tenants.get_by_id(stub_client(__MODULE__), "ten_unknown")
    end
  end

  describe "search/3" do
    test "returns matching tenants" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "searchTenants" => %{
              "edges" => [%{"node" => %{"tenant" => tenant_fixture()}}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%Tenant{}]}} =
               ExPlain.Tenants.search(stub_client(__MODULE__), %{name: "Acme"})
    end
  end

  describe "upsert/2" do
    test "returns upserted tenant" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertTenant" => %{"tenant" => tenant_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %Tenant{}} =
               ExPlain.Tenants.upsert(stub_client(__MODULE__), %{
                 external_id: "ext_01",
                 name: "Acme"
               })
    end
  end

  describe "add_customer/2" do
    test "returns :added on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"addCustomerToTenants" => %{"error" => nil}}
        })
      end)

      assert {:ok, :added} =
               ExPlain.Tenants.add_customer(stub_client(__MODULE__), %{
                 customer_identifier: %{customer_id: "c_01"},
                 tenant_identifiers: [%{external_id: "ext_01"}]
               })
    end
  end

  describe "remove_customer/2" do
    test "returns :removed on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"removeCustomerFromTenants" => %{"error" => nil}}
        })
      end)

      assert {:ok, :removed} =
               ExPlain.Tenants.remove_customer(stub_client(__MODULE__), %{
                 customer_identifier: %{customer_id: "c_01"},
                 tenant_identifiers: [%{external_id: "ext_01"}]
               })
    end
  end

  describe "set_customer_tenants/2" do
    test "returns :set on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"setCustomerTenants" => %{"error" => nil}}
        })
      end)

      assert {:ok, :set} =
               ExPlain.Tenants.set_customer_tenants(stub_client(__MODULE__), %{
                 customer_identifier: %{customer_id: "c_01"},
                 tenant_identifiers: [%{external_id: "ext_01"}]
               })
    end
  end

  describe "update_tier/2" do
    test "returns the tier membership" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "updateTenantTier" => %{
              "tenantTierMembership" => %{"id" => "ttm_01"},
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, %{"id" => "ttm_01"}} =
               ExPlain.Tenants.update_tier(stub_client(__MODULE__), %{
                 tenant_identifier: %{external_id: "ext_01"},
                 tier_identifier: %{tier_id: "tier_01"}
               })
    end
  end

  # ---------------------------------------------------------------------------

  defp tenant_fixture do
    %{
      "id" => "ten_01",
      "name" => "Acme",
      "externalId" => "ext_01",
      "url" => nil,
      "tier" => nil,
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
