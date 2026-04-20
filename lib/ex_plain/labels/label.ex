defmodule ExPlain.Labels.Label do
  @moduledoc "A label applied to a thread."

  alias ExPlain.{Actor, DateTime, Labels.LabelType}

  @enforce_keys [:id, :label_type, :created_at, :updated_at]
  defstruct [:id, :label_type, :created_at, :created_by, :updated_at, :updated_by]

  @type t :: %__MODULE__{
          id: String.t(),
          label_type: LabelType.t(),
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
      label_type: LabelType.from_map(m["labelType"]),
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      updated_by: Actor.from_map(m["updatedBy"])
    }
  end
end
