defmodule ExPlain.CustomersTest do
  use ExUnit.Case, async: true

  alias ExPlain.Customers.Customer

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "get_by_id/2" do
    test "returns a customer when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "customer" => customer_fixture()
          }
        })
      end)

      client = stub_client(__MODULE__)
      assert {:ok, %Customer{id: "c_01HX"}} = ExPlain.Customers.get_by_id(client, "c_01HX")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"customer" => nil}})
      end)

      client = stub_client(__MODULE__)
      assert {:ok, nil} = ExPlain.Customers.get_by_id(client, "c_unknown")
    end
  end

  describe "get_by_email/2" do
    test "returns a customer when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "customerByEmail" => customer_fixture()
          }
        })
      end)

      client = stub_client(__MODULE__)
      assert {:ok, %Customer{}} = ExPlain.Customers.get_by_email(client, "alice@example.com")
    end
  end

  describe "upsert/2" do
    test "returns created customer with result" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertCustomer" => %{
              "result" => "CREATED",
              "customer" => customer_fixture(),
              "error" => nil
            }
          }
        })
      end)

      client = stub_client(__MODULE__)

      input = %{
        identifier: %{email_address: %{email: "alice@example.com"}},
        on_create: %{email: %{email: "alice@example.com"}, full_name: "Alice"},
        on_update: %{}
      }

      assert {:ok, %{result: :created, customer: %Customer{}}} =
               ExPlain.Customers.upsert(client, input)
    end

    test "returns error on mutation failure" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertCustomer" => %{
              "result" => nil,
              "customer" => nil,
              "error" => %{
                "message" => "Email is invalid.",
                "type" => "VALIDATION",
                "code" => "input_validation",
                "fields" => [
                  %{"field" => "email", "message" => "Email is invalid.", "type" => "VALIDATION"}
                ]
              }
            }
          }
        })
      end)

      client = stub_client(__MODULE__)

      input = %{
        identifier: %{email_address: %{email: "bad"}},
        on_create: %{email: %{email: "bad"}, full_name: "Alice"},
        on_update: %{}
      }

      assert {:error, %ExPlain.Error{type: :mutation_error, code: "input_validation"}} =
               ExPlain.Customers.upsert(client, input)
    end
  end

  describe "list/2" do
    test "returns paginated customers" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "customers" => %{
              "edges" => [%{"node" => customer_fixture()}],
              "pageInfo" => %{
                "hasNextPage" => false,
                "hasPreviousPage" => false,
                "startCursor" => "cursor_start",
                "endCursor" => "cursor_end"
              },
              "totalCount" => 1
            }
          }
        })
      end)

      client = stub_client(__MODULE__)

      assert {:ok, %{nodes: [%Customer{}], page_info: %ExPlain.PageInfo{}, total_count: 1}} =
               ExPlain.Customers.list(client, first: 10)
    end

    test "uses default opts when called with client only" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "customers" => %{
              "edges" => [],
              "pageInfo" => %{
                "hasNextPage" => false,
                "hasPreviousPage" => false,
                "startCursor" => nil,
                "endCursor" => nil
              },
              "totalCount" => 0
            }
          }
        })
      end)

      assert {:ok, %{nodes: []}} = ExPlain.Customers.list(stub_client(__MODULE__))
    end
  end

  describe "upsert/2 — unknown result" do
    test "passes through unrecognised result values" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertCustomer" => %{
              "result" => "NOOP",
              "customer" => customer_fixture(),
              "error" => nil
            }
          }
        })
      end)

      client = stub_client(__MODULE__)

      assert {:ok, %{result: "NOOP"}} =
               ExPlain.Customers.upsert(client, %{
                 identifier: %{email_address: %{email: "alice@example.com"}},
                 on_create: %{email: %{email: "alice@example.com"}, full_name: "Alice"},
                 on_update: %{}
               })
    end
  end

  describe "get_by_external_id/2" do
    test "returns a customer when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"customerByExternalId" => customer_fixture()}
        })
      end)

      client = stub_client(__MODULE__)
      assert {:ok, %Customer{}} = ExPlain.Customers.get_by_external_id(client, "ext_123")
    end
  end

  describe "upsert/2 — updated result" do
    test "returns updated customer with result :updated" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertCustomer" => %{
              "result" => "UPDATED",
              "customer" => customer_fixture(),
              "error" => nil
            }
          }
        })
      end)

      client = stub_client(__MODULE__)

      assert {:ok, %{result: :updated}} =
               ExPlain.Customers.upsert(client, %{
                 identifier: %{email_address: %{email: "alice@example.com"}},
                 on_create: %{email: %{email: "alice@example.com"}, full_name: "Alice"},
                 on_update: %{}
               })
    end
  end

  describe "delete/2" do
    test "returns :deleted on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"deleteCustomer" => %{"error" => nil}}
        })
      end)

      client = stub_client(__MODULE__)
      assert {:ok, :deleted} = ExPlain.Customers.delete(client, "c_01HX")
    end
  end

  describe "update_company/2" do
    test "returns updated customer" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "updateCustomerCompany" => %{
              "customer" => customer_with_company_fixture(),
              "error" => nil
            }
          }
        })
      end)

      client = stub_client(__MODULE__)

      assert {:ok, %Customer{company: %ExPlain.Companies.Company{}}} =
               ExPlain.Customers.update_company(client, %{
                 customer_id: "c_01HX",
                 company_identifier: %{domain_name: "example.com"}
               })
    end
  end

  describe "add_to_customer_groups/2" do
    test "returns memberships list" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "addCustomerToCustomerGroups" => %{
              "customerGroupMemberships" => [%{"id" => "cgm_01"}],
              "error" => nil
            }
          }
        })
      end)

      client = stub_client(__MODULE__)

      assert {:ok, [%{"id" => "cgm_01"}]} =
               ExPlain.Customers.add_to_customer_groups(client, %{
                 customer_id: "c_01HX",
                 customer_group_identifiers: [%{customer_group_key: "enterprise"}]
               })
    end
  end

  describe "remove_from_customer_groups/2" do
    test "returns :removed on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"removeCustomerFromCustomerGroups" => %{"error" => nil}}
        })
      end)

      client = stub_client(__MODULE__)

      assert {:ok, :removed} =
               ExPlain.Customers.remove_from_customer_groups(client, %{
                 customer_id: "c_01HX",
                 customer_group_identifiers: [%{customer_group_key: "enterprise"}]
               })
    end
  end

  # ---------------------------------------------------------------------------

  defp customer_fixture do
    %{
      "id" => "c_01HX",
      "fullName" => "Alice Example",
      "shortName" => "Alice",
      "externalId" => "ext_123",
      "email" => %{
        "email" => "alice@example.com",
        "isVerified" => true,
        "verifiedAt" => nil
      },
      "company" => nil,
      "createdAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "createdBy" => %{"__typename" => "UserActor", "userId" => "usr_01HX"},
      "updatedAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "markedAsSpamAt" => nil
    }
  end

  defp customer_with_company_fixture do
    customer_fixture()
    |> Map.put("company", %{
      "id" => "co_01",
      "name" => "Example Corp",
      "domainName" => "example.com",
      "createdAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "createdBy" => nil,
      "updatedAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "updatedBy" => nil
    })
    |> Map.put("email", nil)
  end
end
