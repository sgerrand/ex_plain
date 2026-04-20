defmodule ExPlain.Tiers do
  @moduledoc "Operations for managing tiers in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Tiers.Tier

  import ExPlain.Util,
    only: [check_mutation_error: 1, build_pagination_vars: 1, camelize_keys: 1, wrap_input: 1]

  @doc "Returns a paginated list of tiers."
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [Tier.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    with {:ok, data} <- Client.execute(client, Operations.tiers(), variables) do
      conn = data["tiers"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> Tier.from_map(e["node"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Fetches a tier by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, Tier.t() | nil} | {:error, Error.t()}
  def get_by_id(client, tier_id) do
    with {:ok, data} <- Client.execute(client, Operations.tier_by_id(), %{tierId: tier_id}) do
      {:ok, Tier.from_map(data["tier"])}
    end
  end

  @doc """
  Adds members (tenants or companies) to a tier.

  The `input` map must include `:tier_identifier` and `:member_identifiers`.
  """
  @spec add_members(Client.t(), map()) :: {:ok, list()} | {:error, Error.t()}
  def add_members(client, input) do
    variables = wrap_input(input)

    with {:ok, data} <- Client.execute(client, Operations.add_members_to_tier(), variables),
         :ok <- check_mutation_error(data["addMembersToTier"]["error"]) do
      {:ok, data["addMembersToTier"]["memberships"] || []}
    end
  end

  @doc """
  Removes members from a tier.

  The `input` map must include `:tier_identifier` and `:member_identifiers`.
  """
  @spec remove_members(Client.t(), map()) :: {:ok, :removed} | {:error, Error.t()}
  def remove_members(client, input) do
    variables = wrap_input(input)

    with {:ok, data} <- Client.execute(client, Operations.remove_members_from_tier(), variables),
         :ok <- check_mutation_error(data["removeMembersFromTier"]["error"]) do
      {:ok, :removed}
    end
  end
end
