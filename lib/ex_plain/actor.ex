defmodule ExPlain.Actor do
  @moduledoc """
  Represents who performed an action in Plain.

  The `:type` field discriminates the variant:

    * `:user` — a workspace user (agent). `:user_id` is set.
    * `:customer` — a customer. `:customer_id` is set.
    * `:machine_user` — an API key / machine user. `:machine_user_id` is set.
    * `:system` — the Plain system itself.
    * `:deleted_customer` — a customer that has since been deleted. `:customer_id` is set.
  """

  defstruct [:type, :user_id, :customer_id, :machine_user_id]

  @type actor_type :: :user | :customer | :machine_user | :system | :deleted_customer

  @type t :: %__MODULE__{
          type: actor_type(),
          user_id: String.t() | nil,
          customer_id: String.t() | nil,
          machine_user_id: String.t() | nil
        }

  @doc false
  def from_map(nil), do: nil

  def from_map(%{"__typename" => "UserActor"} = m),
    do: %__MODULE__{type: :user, user_id: m["userId"]}

  def from_map(%{"__typename" => "CustomerActor"} = m),
    do: %__MODULE__{type: :customer, customer_id: m["customerId"]}

  def from_map(%{"__typename" => "SystemActor"}),
    do: %__MODULE__{type: :system}

  def from_map(%{"__typename" => "MachineUserActor"} = m),
    do: %__MODULE__{type: :machine_user, machine_user_id: m["machineUserId"]}

  def from_map(%{"__typename" => "DeletedCustomerActor"} = m),
    do: %__MODULE__{type: :deleted_customer, customer_id: m["customerId"]}
end
