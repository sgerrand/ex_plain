defmodule ExPlain.WebhooksTest do
  use ExUnit.Case, async: true

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "list/2" do
    test "returns paginated webhook targets" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "webhookTargets" => %{
              "edges" => [%{"node" => webhook_fixture()}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%ExPlain.Webhooks.WebhookTarget{id: "wh_01"}]}} =
               ExPlain.Webhooks.list(stub_client(__MODULE__))
    end
  end

  describe "get_by_id/2" do
    test "returns webhook when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"webhookTarget" => webhook_fixture()}})
      end)

      assert {:ok, %ExPlain.Webhooks.WebhookTarget{id: "wh_01"}} =
               ExPlain.Webhooks.get_by_id(stub_client(__MODULE__), "wh_01")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"webhookTarget" => nil}})
      end)

      assert {:ok, nil} = ExPlain.Webhooks.get_by_id(stub_client(__MODULE__), "wh_unknown")
    end
  end

  describe "create/2" do
    test "returns the created webhook target" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createWebhookTarget" => %{"webhookTarget" => webhook_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %ExPlain.Webhooks.WebhookTarget{id: "wh_01"}} =
               ExPlain.Webhooks.create(stub_client(__MODULE__), %{
                 url: "https://example.com/webhook",
                 event_subscriptions: [%{event_type: "thread.thread_created"}]
               })
    end
  end

  describe "update/2" do
    test "returns the updated webhook target" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "updateWebhookTarget" => %{"webhookTarget" => webhook_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %ExPlain.Webhooks.WebhookTarget{id: "wh_01"}} =
               ExPlain.Webhooks.update(stub_client(__MODULE__), %{
                 webhook_target_id: "wh_01",
                 url: "https://example.com/webhook-v2"
               })
    end
  end

  describe "create/2 — error" do
    test "returns error on mutation failure" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createWebhookTarget" => %{
              "webhookTarget" => nil,
              "error" => mutation_error_fixture()
            }
          }
        })
      end)

      assert {:error, %ExPlain.Error{type: :mutation_error}} =
               ExPlain.Webhooks.create(stub_client(__MODULE__), %{
                 url: "https://example.com/webhook",
                 event_subscriptions: [%{event_type: "thread.thread_created"}]
               })
    end
  end

  describe "delete/2" do
    test "returns :deleted on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"deleteWebhookTarget" => %{"error" => nil}}
        })
      end)

      assert {:ok, :deleted} = ExPlain.Webhooks.delete(stub_client(__MODULE__), "wh_01")
    end
  end

  # ---------------------------------------------------------------------------

  defp mutation_error_fixture do
    %{"message" => "Invalid.", "type" => "VALIDATION", "code" => "validation", "fields" => []}
  end

  defp webhook_fixture do
    %{
      "id" => "wh_01",
      "url" => "https://example.com/webhook",
      "isEnabled" => true,
      "description" => nil,
      "eventSubscriptions" => [],
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
