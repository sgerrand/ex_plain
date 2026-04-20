defmodule ExPlain.Customers.Customer do
  @moduledoc "A Plain customer."

  alias ExPlain.{Actor, DateTime}
  alias ExPlain.Companies.Company

  @enforce_keys [:id, :full_name, :email, :created_at, :updated_at]
  defstruct [
    :id,
    :full_name,
    :short_name,
    :external_id,
    :email,
    :company,
    :created_at,
    :created_by,
    :updated_at,
    :marked_as_spam_at
  ]

  @type email :: %{email: String.t(), is_verified: boolean(), verified_at: DateTime.t() | nil}

  @type t :: %__MODULE__{
          id: String.t(),
          full_name: String.t(),
          short_name: String.t() | nil,
          external_id: String.t() | nil,
          email: email(),
          company: ExPlain.Companies.Company.t() | nil,
          created_at: DateTime.t(),
          created_by: Actor.t() | nil,
          updated_at: DateTime.t(),
          marked_as_spam_at: DateTime.t() | nil
        }

  @doc false
  def from_map(nil), do: nil

  def from_map(m) do
    %__MODULE__{
      id: m["id"],
      full_name: m["fullName"],
      short_name: m["shortName"],
      external_id: m["externalId"],
      email: decode_email(m["email"]),
      company: decode_company(m["company"]),
      created_at: DateTime.from_map(m["createdAt"]),
      created_by: Actor.from_map(m["createdBy"]),
      updated_at: DateTime.from_map(m["updatedAt"]),
      marked_as_spam_at: DateTime.from_map(m["markedAsSpamAt"])
    }
  end

  defp decode_email(nil), do: nil

  defp decode_email(e) do
    %{
      email: e["email"],
      is_verified: e["isVerified"],
      verified_at: DateTime.from_map(e["verifiedAt"])
    }
  end

  defp decode_company(nil), do: nil
  defp decode_company(c), do: Company.from_map(c)
end
