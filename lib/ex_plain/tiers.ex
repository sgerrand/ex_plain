defmodule ExPlain.Tiers do
  @moduledoc "Operations for managing tiers in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Tiers.Tier

  import ExPlain.Util,
    only: [
      build_pagination_vars: 1,
      wrap_input: 1,
      fetch_one: 5,
      list_connection: 5,
      run_mutation: 5
    ]

  @doc "Returns a paginated list of tiers."
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [Tier.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    list_connection(client, Operations.tiers(), variables, "tiers", &Tier.from_map/1)
  end

  @doc """
  Fetches a tier by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, Tier.t() | nil} | {:error, Error.t()}
  def get_by_id(client, tier_id) do
    fetch_one(client, Operations.tier_by_id(), %{tierId: tier_id}, "tier", &Tier.from_map/1)
  end

  @doc """
  Adds members (tenants or companies) to a tier.

  The `input` map must include `:tier_identifier` and `:member_identifiers`.
  """
  @spec add_members(Client.t(), map()) :: {:ok, list()} | {:error, Error.t()}
  def add_members(client, input) do
    run_mutation(
      client,
      Operations.add_members_to_tier(),
      wrap_input(input),
      "addMembersToTier",
      &(&1["memberships"] || [])
    )
  end

  @doc """
  Removes members from a tier.

  The `input` map must include `:tier_identifier` and `:member_identifiers`.
  """
  @spec remove_members(Client.t(), map()) :: {:ok, :removed} | {:error, Error.t()}
  def remove_members(client, input) do
    run_mutation(
      client,
      Operations.remove_members_from_tier(),
      wrap_input(input),
      "removeMembersFromTier",
      fn _ -> :removed end
    )
  end
end
