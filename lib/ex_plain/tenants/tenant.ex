defmodule ExPlain.Tenants.Tenant do
  @moduledoc "A Plain tenant (a logical workspace/account grouping your customers)."

  alias ExPlain.{Actor, DateTime, Tiers.Tier}

  @enforce_keys [:id, :name, :external_id, :created_at, :updated_at]
  defstruct [
    :id,
    :name,
    :external_id,
    :url,
    :tier,
    :created_at,
    :created_by,
    :updated_at,
    :updated_by
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          external_id: String.t(),
          url: String.t() | nil,
          tier: Tier.t() | nil,
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
      external_id: m["externalId"],
      url: m["url"],
      tier: Tier.from_map(m["tier"]),
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      updated_by: Actor.from_map(m["updatedBy"])
    }
  end
end
