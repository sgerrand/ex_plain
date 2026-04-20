defmodule ExPlain.Threads.Thread do
  @moduledoc "A Plain support thread."

  alias ExPlain.{Actor, DateTime, Labels.Label, Tenants.Tenant}

  @enforce_keys [:id, :ref, :status, :priority, :status_changed_at, :created_at, :updated_at]
  defstruct [
    :id,
    :ref,
    :external_id,
    :customer_id,
    :status,
    :status_detail,
    :status_changed_at,
    :title,
    :description,
    :preview_text,
    :priority,
    :tenant,
    :labels,
    :thread_fields,
    :assigned_at,
    :assigned_to,
    :locked_at,
    :created_at,
    :created_by,
    :updated_at,
    :updated_by
  ]

  @type thread_status :: :todo | :snoozed | :done
  @type thread_field :: map()
  @type thread_assignee :: map()
  @type status_detail :: map() | nil

  @type t :: %__MODULE__{
          id: String.t(),
          ref: String.t(),
          external_id: String.t() | nil,
          customer_id: String.t() | nil,
          status: thread_status(),
          status_detail: status_detail(),
          status_changed_at: DateTime.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          preview_text: String.t() | nil,
          priority: integer(),
          tenant: Tenant.t() | nil,
          labels: [Label.t()],
          thread_fields: [thread_field()],
          assigned_at: DateTime.t() | nil,
          assigned_to: thread_assignee() | nil,
          locked_at: DateTime.t() | nil,
          created_at: DateTime.t(),
          created_by: Actor.t() | nil,
          updated_at: DateTime.t(),
          updated_by: Actor.t() | nil
        }

  @doc false
  def from_map(nil), do: nil

  def from_map(m) do
    %__MODULE__{
      id: m["id"],
      ref: m["ref"],
      external_id: m["externalId"],
      customer_id: get_in(m, ["customer", "id"]),
      status: decode_status(m["status"]),
      status_detail: decode_status_detail(m["statusDetail"]),
      status_changed_at: DateTime.from_map(m["statusChangedAt"]),
      title: m["title"],
      description: m["description"],
      preview_text: m["previewText"],
      priority: m["priority"],
      tenant: Tenant.from_map(m["tenant"]),
      labels: Enum.map(m["labels"] || [], &Label.from_map/1),
      thread_fields: Enum.map(m["threadFields"] || [], &decode_thread_field/1),
      assigned_at: DateTime.from_map(m["assignedAt"]),
      assigned_to: decode_assignee(m["assignedTo"]),
      locked_at: DateTime.from_map(m["lockedAt"]),
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      updated_by: Actor.from_map(m["updatedBy"])
    }
  end

  defp decode_status("TODO"), do: :todo
  defp decode_status("SNOOZED"), do: :snoozed
  defp decode_status("DONE"), do: :done
  defp decode_status(s), do: s

  defp decode_status_detail(nil), do: nil

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailCreated"} = d),
    do: %{type: :created, created_at: DateTime.from_map(d["createdAt"])}

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailNewReply"} = d),
    do: %{type: :new_reply, status_changed_at: DateTime.from_map(d["statusChangedAt"])}

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailInProgress"} = d),
    do: %{type: :in_progress, status_changed_at: DateTime.from_map(d["statusChangedAt"])}

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailWaitingForCustomer"} = d),
    do: %{type: :waiting_for_customer, status_changed_at: DateTime.from_map(d["statusChangedAt"])}

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailDoneManuallySet"} = d),
    do: %{type: :done_manually_set, status_changed_at: DateTime.from_map(d["statusChangedAt"])}

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailIgnored"} = d),
    do: %{type: :ignored, status_changed_at: DateTime.from_map(d["statusChangedAt"])}

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailThreadDiscussionResolved"} = d) do
    %{
      type: :thread_discussion_resolved,
      thread_discussion_id: d["threadDiscussionId"],
      status_changed_at: DateTime.from_map(d["statusChangedAt"])
    }
  end

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailThreadLinkUpdated"} = d) do
    %{
      type: :thread_link_updated,
      linear_issue_id: d["linearIssueId"],
      status_changed_at: DateTime.from_map(d["statusChangedAt"])
    }
  end

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailWaitingForDuration"} = d) do
    %{
      type: :waiting_for_duration,
      status_changed_at: DateTime.from_map(d["statusChangedAt"]),
      waiting_until: DateTime.from_map(d["waitingUntil"])
    }
  end

  defp decode_status_detail(%{"__typename" => "ThreadStatusDetailDoneAutomaticallySet"} = d) do
    %{
      type: :done_automatically_set,
      after_seconds: d["afterSeconds"],
      status_changed_at: DateTime.from_map(d["statusChangedAt"])
    }
  end

  defp decode_status_detail(%{"__typename" => typename}),
    do: %{type: :unknown, typename: typename}

  defp decode_assignee(nil), do: nil

  defp decode_assignee(%{"__typename" => "User"} = u) do
    %{
      type: :user,
      id: u["id"],
      full_name: u["fullName"],
      public_name: u["publicName"],
      email: u["email"],
      updated_at: DateTime.from_map(u["updatedAt"])
    }
  end

  defp decode_assignee(%{"__typename" => "MachineUser"} = u) do
    %{type: :machine_user, id: u["id"], full_name: u["fullName"], public_name: u["publicName"]}
  end

  defp decode_assignee(%{"__typename" => "System"}), do: %{type: :system}

  defp decode_thread_field(nil), do: nil

  defp decode_thread_field(f) do
    %{
      id: f["id"],
      key: f["key"],
      type: f["type"],
      thread_id: f["threadId"],
      string_value: f["stringValue"],
      boolean_value: f["booleanValue"],
      is_ai_generated: f["isAiGenerated"],
      created_at: DateTime.from_map(f["createdAt"]),
      updated_at: DateTime.from_map(f["updatedAt"])
    }
  end
end
