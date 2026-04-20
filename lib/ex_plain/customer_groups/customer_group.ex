defmodule ExPlain.CustomerGroups.CustomerGroup do
  @moduledoc "A Plain customer group."

  alias ExPlain.DateTime

  @enforce_keys [:id, :key, :name, :color, :created_at, :updated_at]
  defstruct [:id, :key, :name, :color, :external_id, :created_at, :updated_at]

  @type t :: %__MODULE__{
          id: String.t(),
          key: String.t(),
          name: String.t(),
          color: String.t(),
          external_id: String.t() | nil,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def from_map(nil), do: nil

  def from_map(m) do
    %__MODULE__{
      id: m["id"],
      key: m["key"],
      name: m["name"],
      color: m["color"],
      external_id: m["externalId"],
      created_at: DateTime.from_map(m["createdAt"]),
      updated_at: DateTime.from_map(m["updatedAt"])
    }
  end
end
