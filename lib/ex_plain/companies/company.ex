defmodule ExPlain.Companies.Company do
  @moduledoc "A Plain company."

  alias ExPlain.{Actor, DateTime}

  @enforce_keys [:id, :name, :domain_name, :created_at, :updated_at]
  defstruct [:id, :name, :domain_name, :created_at, :created_by, :updated_at, :updated_by]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          domain_name: String.t(),
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
      domain_name: m["domainName"],
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      updated_by: Actor.from_map(m["updatedBy"])
    }
  end
end
