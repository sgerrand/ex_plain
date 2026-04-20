defmodule ExPlain.Events.ThreadEvent do
  @moduledoc "A custom event on a thread's timeline."

  alias ExPlain.{Actor, DateTime}

  @enforce_keys [:id, :thread_id, :customer_id, :title, :created_at, :updated_at]
  defstruct [
    :id,
    :thread_id,
    :customer_id,
    :title,
    :created_at,
    :created_by,
    :updated_at,
    :updated_by
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          thread_id: String.t(),
          customer_id: String.t(),
          title: String.t(),
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
      thread_id: m["threadId"],
      customer_id: m["customerId"],
      title: m["title"],
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      updated_by: Actor.from_map(m["updatedBy"])
    }
  end
end
