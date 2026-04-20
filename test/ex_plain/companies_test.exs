defmodule ExPlain.CompaniesTest do
  use ExUnit.Case, async: true

  alias ExPlain.Companies.Company

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "Company.from_map/1" do
    test "returns nil for nil" do
      assert nil == Company.from_map(nil)
    end
  end

  describe "list/2" do
    test "returns paginated companies" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "companies" => %{
              "edges" => [%{"node" => company_fixture()}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%Company{}], page_info: %ExPlain.PageInfo{}}} =
               ExPlain.Companies.list(stub_client(__MODULE__))
    end
  end

  describe "search/3" do
    test "returns matching companies" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "searchCompanies" => %{
              "edges" => [%{"node" => %{"company" => company_fixture()}}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%Company{}]}} =
               ExPlain.Companies.search(stub_client(__MODULE__), %{name: "Acme"})
    end
  end

  describe "upsert/2" do
    test "returns the upserted company" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertCompany" => %{"company" => company_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %Company{}} =
               ExPlain.Companies.upsert(stub_client(__MODULE__), %{
                 domain_name: "acme.com",
                 name: "Acme"
               })
    end

    test "returns error on mutation failure" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertCompany" => %{
              "company" => nil,
              "error" => mutation_error_fixture()
            }
          }
        })
      end)

      assert {:error, %ExPlain.Error{type: :mutation_error}} =
               ExPlain.Companies.upsert(stub_client(__MODULE__), %{domain_name: "bad"})
    end
  end

  describe "update_tier/2" do
    test "returns the tier membership" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "updateCompanyTier" => %{
              "companyTierMembership" => %{"id" => "ctm_01"},
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, %{"id" => "ctm_01"}} =
               ExPlain.Companies.update_tier(stub_client(__MODULE__), %{
                 company_identifier: %{domain_name: "acme.com"},
                 tier_identifier: %{tier_id: "tier_01"}
               })
    end
  end

  # ---------------------------------------------------------------------------

  defp company_fixture do
    %{
      "id" => "co_01",
      "name" => "Acme Corp",
      "domainName" => "acme.com",
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

  defp mutation_error_fixture do
    %{
      "message" => "Invalid input.",
      "type" => "VALIDATION",
      "code" => "input_validation",
      "fields" => []
    }
  end
end
