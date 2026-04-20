defmodule ExPlain.Users.User do
  @moduledoc "A workspace user (agent) in Plain."

  alias ExPlain.DateTime

  @enforce_keys [:id, :full_name, :public_name, :email, :updated_at]
  defstruct [:id, :full_name, :public_name, :email, :updated_at]

  @type t :: %__MODULE__{
          id: String.t(),
          full_name: String.t(),
          public_name: String.t(),
          email: String.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def from_map(nil), do: nil

  def from_map(m) do
    %__MODULE__{
      id: m["id"],
      full_name: m["fullName"],
      public_name: m["publicName"],
      email: m["email"],
      updated_at: DateTime.from_map(m["updatedAt"])
    }
  end
end
