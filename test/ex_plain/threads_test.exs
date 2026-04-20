defmodule ExPlain.ThreadsTest do
  use ExUnit.Case, async: true

  alias ExPlain.Threads.Thread

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "list/2" do
    test "returns paginated threads" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "threads" => %{
              "edges" => [%{"node" => thread_fixture()}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%Thread{}]}} = ExPlain.Threads.list(stub_client(__MODULE__))
    end
  end

  describe "get_by_id/2" do
    test "returns thread when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"thread" => thread_fixture()}})
      end)

      assert {:ok, %Thread{id: "th_01"}} =
               ExPlain.Threads.get_by_id(stub_client(__MODULE__), "th_01")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"thread" => nil}})
      end)

      assert {:ok, nil} = ExPlain.Threads.get_by_id(stub_client(__MODULE__), "th_unknown")
    end
  end

  describe "get_by_ref/2" do
    test "returns thread when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"threadByRef" => thread_fixture()}})
      end)

      assert {:ok, %Thread{}} = ExPlain.Threads.get_by_ref(stub_client(__MODULE__), "T-1")
    end
  end

  describe "get_by_external_id/3" do
    test "returns thread when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"threadByExternalId" => thread_fixture()}})
      end)

      assert {:ok, %Thread{}} =
               ExPlain.Threads.get_by_external_id(stub_client(__MODULE__), "c_01", "ext_01")
    end
  end

  describe "create/2" do
    test "returns created thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createThread" => %{"thread" => thread_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %Thread{}} =
               ExPlain.Threads.create(stub_client(__MODULE__), %{
                 customer_identifier: %{customer_id: "c_01"},
                 title: "Cannot log in"
               })
    end

    test "returns error on mutation failure" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createThread" => %{"thread" => nil, "error" => mutation_error_fixture()}
          }
        })
      end)

      assert {:error, %ExPlain.Error{type: :mutation_error}} =
               ExPlain.Threads.create(stub_client(__MODULE__), %{
                 customer_identifier: %{customer_id: "c_01"}
               })
    end
  end

  describe "assign/3" do
    test "returns updated thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "assignThread" => %{"thread" => thread_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %Thread{}} =
               ExPlain.Threads.assign(stub_client(__MODULE__), "th_01", user_id: "usr_01")
    end
  end

  describe "unassign/2" do
    test "returns updated thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"unassignThread" => %{"thread" => thread_fixture(), "error" => nil}}
        })
      end)

      assert {:ok, %Thread{}} = ExPlain.Threads.unassign(stub_client(__MODULE__), "th_01")
    end
  end

  describe "change_priority/3" do
    test "returns updated thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "changeThreadPriority" => %{"thread" => thread_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %Thread{}} =
               ExPlain.Threads.change_priority(stub_client(__MODULE__), "th_01", 1)
    end
  end

  describe "update_tenant/2" do
    test "returns updated thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "updateThreadTenant" => %{"thread" => thread_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %Thread{}} =
               ExPlain.Threads.update_tenant(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 tenant_identifier: %{external_id: "ext_01"}
               })
    end
  end

  describe "mark_as_done/2" do
    test "returns updated thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "markThreadAsDone" => %{"thread" => thread_fixture("DONE"), "error" => nil}
          }
        })
      end)

      assert {:ok, %Thread{status: :done}} =
               ExPlain.Threads.mark_as_done(stub_client(__MODULE__), "th_01")
    end
  end

  describe "snooze/3" do
    test "returns snoozed thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "snoozeThread" => %{"thread" => thread_fixture("SNOOZED"), "error" => nil}
          }
        })
      end)

      assert {:ok, %Thread{status: :snoozed}} =
               ExPlain.Threads.snooze(stub_client(__MODULE__), "th_01", 3600)
    end
  end

  describe "mark_as_todo/2" do
    test "returns updated thread" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "markThreadAsTodo" => %{"thread" => thread_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %Thread{}} = ExPlain.Threads.mark_as_todo(stub_client(__MODULE__), "th_01")
    end
  end

  describe "reply/2" do
    test "returns :sent on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{"replyToThread" => %{"error" => nil}}
        })
      end)

      assert {:ok, :sent} =
               ExPlain.Threads.reply(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 components: []
               })
    end
  end

  describe "send_chat/2" do
    test "returns chat map on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "sendChat" => %{"chat" => %{"id" => "chat_01"}, "error" => nil}
          }
        })
      end)

      assert {:ok, %{"id" => "chat_01"}} =
               ExPlain.Threads.send_chat(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 text: "Hello"
               })
    end
  end

  describe "send_customer_chat/2" do
    test "returns chat map on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "sendCustomerChat" => %{"chat" => %{"id" => "chat_02"}, "error" => nil}
          }
        })
      end)

      assert {:ok, %{"id" => "chat_02"}} =
               ExPlain.Threads.send_customer_chat(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 text: "Hi there"
               })
    end
  end

  describe "send_email/2" do
    test "returns :sent on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"sendNewEmail" => %{"error" => nil}}})
      end)

      assert {:ok, :sent} =
               ExPlain.Threads.send_email(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 components: []
               })
    end
  end

  describe "reply_to_email/2" do
    test "returns :sent on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"replyToEmail" => %{"error" => nil}}})
      end)

      assert {:ok, :sent} =
               ExPlain.Threads.reply_to_email(stub_client(__MODULE__), %{
                 email_id: "em_01",
                 components: []
               })
    end
  end

  describe "create_note/2" do
    test "returns note map on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createNote" => %{"note" => %{"id" => "note_01"}, "error" => nil}
          }
        })
      end)

      assert {:ok, %{"id" => "note_01"}} =
               ExPlain.Threads.create_note(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 markdown: "Internal note"
               })
    end
  end

  describe "add_labels/3" do
    test "returns labels list on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "addLabels" => %{
              "labels" => [label_fixture()],
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, [%ExPlain.Labels.Label{}]} =
               ExPlain.Threads.add_labels(stub_client(__MODULE__), "th_01", ["lbt_01"])
    end
  end

  describe "remove_labels/2" do
    test "returns :removed on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"removeLabels" => %{"error" => nil}}})
      end)

      assert {:ok, :removed} =
               ExPlain.Threads.remove_labels(stub_client(__MODULE__), ["lbl_01"])
    end
  end

  describe "upsert_field/2" do
    test "returns thread field map on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "upsertThreadField" => %{
              "threadField" => %{"id" => "tf_01"},
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, %{"id" => "tf_01"}} =
               ExPlain.Threads.upsert_field(stub_client(__MODULE__), %{
                 thread_id: "th_01",
                 key: "order_id",
                 type: "STRING",
                 string_value: "ord_123"
               })
    end
  end

  describe "delete_field/2" do
    test "returns :deleted on success" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"deleteThreadField" => %{"error" => nil}}})
      end)

      assert {:ok, :deleted} =
               ExPlain.Threads.delete_field(stub_client(__MODULE__), "tf_01")
    end
  end

  describe "Thread.from_map/1 — status variants" do
    test "decodes TODO status" do
      assert %Thread{status: :todo} = Thread.from_map(thread_fixture("TODO"))
    end

    test "decodes SNOOZED status" do
      assert %Thread{status: :snoozed} = Thread.from_map(thread_fixture("SNOOZED"))
    end

    test "decodes DONE status" do
      assert %Thread{status: :done} = Thread.from_map(thread_fixture("DONE"))
    end

    test "passes through unknown status as-is" do
      assert %Thread{status: "CUSTOM"} = Thread.from_map(thread_fixture("CUSTOM"))
    end
  end

  describe "Thread.from_map/1 — status_detail variants" do
    for {typename, extra} <- [
          {"ThreadStatusDetailCreated",
           %{
             "createdAt" => %{
               "iso8601" => "2024-01-01T00:00:00Z",
               "unixTimestamp" => "1704067200"
             }
           }},
          {"ThreadStatusDetailNewReply",
           %{
             "statusChangedAt" => %{
               "iso8601" => "2024-01-01T00:00:00Z",
               "unixTimestamp" => "1704067200"
             }
           }},
          {"ThreadStatusDetailInProgress",
           %{
             "statusChangedAt" => %{
               "iso8601" => "2024-01-01T00:00:00Z",
               "unixTimestamp" => "1704067200"
             }
           }},
          {"ThreadStatusDetailWaitingForCustomer",
           %{
             "statusChangedAt" => %{
               "iso8601" => "2024-01-01T00:00:00Z",
               "unixTimestamp" => "1704067200"
             }
           }},
          {"ThreadStatusDetailDoneManuallySet",
           %{
             "statusChangedAt" => %{
               "iso8601" => "2024-01-01T00:00:00Z",
               "unixTimestamp" => "1704067200"
             }
           }},
          {"ThreadStatusDetailIgnored",
           %{
             "statusChangedAt" => %{
               "iso8601" => "2024-01-01T00:00:00Z",
               "unixTimestamp" => "1704067200"
             }
           }}
        ] do
      @typename typename
      @extra extra
      test "decodes #{typename}" do
        fixture =
          thread_fixture()
          |> Map.put("statusDetail", Map.merge(%{"__typename" => @typename}, @extra))

        assert %Thread{status_detail: %{type: _}} = Thread.from_map(fixture)
      end
    end

    test "decodes ThreadStatusDetailThreadDiscussionResolved" do
      fixture =
        thread_fixture()
        |> Map.put("statusDetail", %{
          "__typename" => "ThreadStatusDetailThreadDiscussionResolved",
          "threadDiscussionId" => "disc_01",
          "statusChangedAt" => dt_fixture()
        })

      assert %Thread{status_detail: %{type: :thread_discussion_resolved}} =
               Thread.from_map(fixture)
    end

    test "decodes ThreadStatusDetailThreadLinkUpdated" do
      fixture =
        thread_fixture()
        |> Map.put("statusDetail", %{
          "__typename" => "ThreadStatusDetailThreadLinkUpdated",
          "linearIssueId" => "lin_01",
          "statusChangedAt" => dt_fixture()
        })

      assert %Thread{status_detail: %{type: :thread_link_updated}} = Thread.from_map(fixture)
    end

    test "decodes ThreadStatusDetailWaitingForDuration" do
      fixture =
        thread_fixture()
        |> Map.put("statusDetail", %{
          "__typename" => "ThreadStatusDetailWaitingForDuration",
          "statusChangedAt" => dt_fixture(),
          "waitingUntil" => dt_fixture()
        })

      assert %Thread{status_detail: %{type: :waiting_for_duration}} = Thread.from_map(fixture)
    end

    test "decodes ThreadStatusDetailDoneAutomaticallySet" do
      fixture =
        thread_fixture()
        |> Map.put("statusDetail", %{
          "__typename" => "ThreadStatusDetailDoneAutomaticallySet",
          "afterSeconds" => 86_400,
          "statusChangedAt" => dt_fixture()
        })

      assert %Thread{status_detail: %{type: :done_automatically_set}} = Thread.from_map(fixture)
    end

    test "handles unknown status_detail typename" do
      fixture =
        thread_fixture()
        |> Map.put("statusDetail", %{"__typename" => "SomeFutureType"})

      assert %Thread{status_detail: %{type: :unknown, typename: "SomeFutureType"}} =
               Thread.from_map(fixture)
    end
  end

  describe "Thread.from_map/1 — assignee variants" do
    test "decodes User assignee" do
      fixture =
        thread_fixture()
        |> Map.put("assignedTo", %{
          "__typename" => "User",
          "id" => "usr_01",
          "fullName" => "Alice",
          "publicName" => "Alice",
          "email" => "alice@example.com",
          "updatedAt" => dt_fixture()
        })

      assert %Thread{assigned_to: %{type: :user, id: "usr_01"}} = Thread.from_map(fixture)
    end

    test "decodes MachineUser assignee" do
      fixture =
        thread_fixture()
        |> Map.put("assignedTo", %{
          "__typename" => "MachineUser",
          "id" => "mu_01",
          "fullName" => "Bot",
          "publicName" => "Bot"
        })

      assert %Thread{assigned_to: %{type: :machine_user}} = Thread.from_map(fixture)
    end

    test "decodes System assignee" do
      fixture = thread_fixture() |> Map.put("assignedTo", %{"__typename" => "System"})
      assert %Thread{assigned_to: %{type: :system}} = Thread.from_map(fixture)
    end
  end

  describe "Thread.from_map/1 — thread fields" do
    test "decodes thread fields" do
      fixture =
        thread_fixture()
        |> Map.put("threadFields", [
          %{
            "id" => "tf_01",
            "key" => "order_id",
            "type" => "STRING",
            "threadId" => "th_01",
            "stringValue" => "ord_123",
            "booleanValue" => nil,
            "isAiGenerated" => false,
            "createdAt" => dt_fixture(),
            "updatedAt" => dt_fixture()
          }
        ])

      assert %Thread{thread_fields: [%{key: "order_id"}]} = Thread.from_map(fixture)
    end

    test "handles nil thread field entries" do
      fixture = thread_fixture() |> Map.put("threadFields", [nil])
      assert %Thread{thread_fields: [nil]} = Thread.from_map(fixture)
    end
  end

  # ---------------------------------------------------------------------------

  defp dt_fixture, do: %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"}

  defp thread_fixture(status \\ "TODO") do
    %{
      "id" => "th_01",
      "ref" => "T-1",
      "externalId" => nil,
      "customer" => %{"id" => "c_01"},
      "status" => status,
      "statusDetail" => nil,
      "statusChangedAt" => dt_fixture(),
      "title" => "Cannot log in",
      "description" => nil,
      "previewText" => nil,
      "priority" => 2,
      "tenant" => nil,
      "labels" => [],
      "threadFields" => [],
      "assignedAt" => nil,
      "assignedTo" => nil,
      "lockedAt" => nil,
      "createdAt" => dt_fixture(),
      "createdBy" => %{"__typename" => "UserActor", "userId" => "usr_01"},
      "updatedAt" => dt_fixture(),
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

  defp label_fixture do
    %{
      "id" => "lbl_01",
      "labelType" => %{
        "id" => "lbt_01",
        "name" => "Bug",
        "icon" => nil,
        "isArchived" => false,
        "archivedAt" => nil,
        "archivedBy" => nil,
        "createdAt" => dt_fixture(),
        "createdBy" => nil,
        "updatedAt" => dt_fixture(),
        "updatedBy" => nil
      },
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
