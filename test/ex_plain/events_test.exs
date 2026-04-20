defmodule ExPlain.EventsTest do
  use ExUnit.Case, async: true

  alias ExPlain.Events.{CustomerEvent, ThreadEvent}

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "CustomerEvent.from_map/1" do
    test "returns nil for nil" do
      assert nil == CustomerEvent.from_map(nil)
    end
  end

  describe "ThreadEvent.from_map/1" do
    test "returns nil for nil" do
      assert nil == ThreadEvent.from_map(nil)
    end
  end

  describe "create_customer_event/2" do
    test "returns the created customer event" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createCustomerEvent" => %{
              "customerEvent" => customer_event_fixture(),
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, %CustomerEvent{id: "ce_01"}} =
               ExPlain.Events.create_customer_event(stub_client(__MODULE__), %{
                 customer_identifier: %{customer_id: "c_01"},
                 title: "Subscription upgraded",
                 components: []
               })
    end

    test "returns error on mutation failure" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createCustomerEvent" => %{
              "customerEvent" => nil,
              "error" => mutation_error_fixture()
            }
          }
        })
      end)

      assert {:error, %ExPlain.Error{type: :mutation_error}} =
               ExPlain.Events.create_customer_event(stub_client(__MODULE__), %{
                 customer_identifier: %{customer_id: "c_01"},
                 title: "",
                 components: []
               })
    end
  end

  describe "create_thread_event/2" do
    test "returns the created thread event" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createThreadEvent" => %{
              "threadEvent" => thread_event_fixture(),
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, %ThreadEvent{id: "te_01"}} =
               ExPlain.Events.create_thread_event(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 title: "Webhook sent",
                 components: []
               })
    end
  end

  # ---------------------------------------------------------------------------

  defp dt_fixture, do: %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"}

  defp customer_event_fixture do
    %{
      "id" => "ce_01",
      "customerId" => "c_01",
      "title" => "Subscription upgraded",
      "createdAt" => dt_fixture(),
      "createdBy" => nil,
      "updatedAt" => dt_fixture(),
      "updatedBy" => nil
    }
  end

  defp thread_event_fixture do
    %{
      "id" => "te_01",
      "threadId" => "th_01",
      "customerId" => "c_01",
      "title" => "Webhook sent",
      "createdAt" => dt_fixture(),
      "createdBy" => nil,
      "updatedAt" => dt_fixture(),
      "updatedBy" => nil
    }
  end

  defp mutation_error_fixture do
    %{"message" => "Invalid.", "type" => "VALIDATION", "code" => "validation", "fields" => []}
  end
end
