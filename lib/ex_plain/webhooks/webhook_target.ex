defmodule ExPlain.Webhooks.WebhookTarget do
  @moduledoc "A Plain webhook target."

  alias ExPlain.{Actor, DateTime}

  @enforce_keys [:id, :url, :is_enabled, :created_at, :updated_at]
  defstruct [
    :id,
    :url,
    :is_enabled,
    :description,
    :event_subscriptions,
    :created_at,
    :created_by,
    :updated_at,
    :updated_by
  ]

  @type event_subscription :: %{event_type: String.t()}

  @type t :: %__MODULE__{
          id: String.t(),
          url: String.t(),
          is_enabled: boolean(),
          description: String.t() | nil,
          event_subscriptions: [event_subscription()],
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
      url: m["url"],
      is_enabled: m["isEnabled"],
      description: m["description"],
      event_subscriptions: decode_event_subscriptions(m["eventSubscriptions"]),
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      updated_by: Actor.from_map(m["updatedBy"])
    }
  end

  defp decode_event_subscriptions(nil), do: []

  defp decode_event_subscriptions(list) do
    Enum.map(list, fn s -> %{event_type: s["eventType"]} end)
  end
end
