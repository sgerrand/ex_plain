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
end
