defmodule ExPlain.Labels.LabelType do
  @moduledoc "A label type (category) in Plain."

  alias ExPlain.{Actor, DateTime}

  @enforce_keys [:id, :name, :is_archived, :created_at, :updated_at]
  defstruct [
    :id,
    :name,
    :icon,
    :is_archived,
    :archived_at,
    :archived_by,
    :created_at,
    :created_by,
    :updated_at,
    :updated_by
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          icon: String.t() | nil,
          is_archived: boolean(),
          archived_at: DateTime.t() | nil,
          archived_by: Actor.t() | nil,
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
      name: m["name"],
      icon: m["icon"],
      is_archived: m["isArchived"],
      archived_at: DateTime.from_map(m["archivedAt"]),
      archived_by: Actor.from_map(m["archivedBy"]),
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      updated_by: Actor.from_map(m["updatedBy"])
    }
  end
end
