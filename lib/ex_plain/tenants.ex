defmodule ExPlain.Tenants do
  @moduledoc "Operations for managing tenants in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Tenants.Tenant

  import ExPlain.Util,
    only: [check_mutation_error: 1, build_pagination_vars: 1, camelize_keys: 1, wrap_input: 1]

  @doc """
  Returns a paginated list of tenants.
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [Tenant.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    with {:ok, data} <- Client.execute(client, Operations.tenants(), variables) do
      conn = data["tenants"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> Tenant.from_map(e["node"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Fetches a tenant by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, Tenant.t() | nil} | {:error, Error.t()}
  def get_by_id(client, tenant_id) do
    with {:ok, data} <- Client.execute(client, Operations.tenant_by_id(), %{tenantId: tenant_id}) do
      {:ok, Tenant.from_map(data["tenant"])}
    end
  end

  @doc """
  Searches tenants by name or external ID.

  The `search_query` map must include `:name` or `:external_id`.
  """
  @spec search(Client.t(), map(), keyword()) ::
          {:ok, %{nodes: [Tenant.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def search(client, search_query, opts \\ []) do
    variables = build_pagination_vars(opts) |> Map.put(:searchQuery, camelize_keys(search_query))

    with {:ok, data} <- Client.execute(client, Operations.search_tenants(), variables) do
      conn = data["searchTenants"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> Tenant.from_map(e["node"]["tenant"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Creates or updates a tenant.

  The `input` map must include `:external_id` and `:name`.
  """
  @spec upsert(Client.t(), map()) :: {:ok, Tenant.t()} | {:error, Error.t()}
  def upsert(client, input) do
    variables = wrap_input(input)

    with {:ok, data} <- Client.execute(client, Operations.upsert_tenant(), variables),
         :ok <- check_mutation_error(data["upsertTenant"]["error"]) do
      {:ok, Tenant.from_map(data["upsertTenant"]["tenant"])}
    end
  end

  @doc """
  Adds a customer to one or more tenants.

  The `input` map must include `:customer_identifier` and `:tenant_identifiers`.
  """
  @spec add_customer(Client.t(), map()) :: {:ok, :added} | {:error, Error.t()}
  def add_customer(client, input) do
    variables = wrap_input(input)

    with {:ok, data} <- Client.execute(client, Operations.add_customer_to_tenants(), variables),
         :ok <- check_mutation_error(data["addCustomerToTenants"]["error"]) do
      {:ok, :added}
    end
  end

  @doc """
  Removes a customer from one or more tenants.

  The `input` map must include `:customer_identifier` and `:tenant_identifiers`.
  """
  @spec remove_customer(Client.t(), map()) :: {:ok, :removed} | {:error, Error.t()}
  def remove_customer(client, input) do
    variables = wrap_input(input)

    with {:ok, data} <-
           Client.execute(client, Operations.remove_customer_from_tenants(), variables),
         :ok <- check_mutation_error(data["removeCustomerFromTenants"]["error"]) do
      {:ok, :removed}
    end
  end

  @doc """
  Sets the exact list of tenants a customer belongs to, replacing any existing memberships.

  The `input` map must include `:customer_identifier` and `:tenant_identifiers`.
  """
  @spec set_customer_tenants(Client.t(), map()) :: {:ok, :set} | {:error, Error.t()}
  def set_customer_tenants(client, input) do
    variables = wrap_input(input)

    with {:ok, data} <- Client.execute(client, Operations.set_customer_tenants(), variables),
         :ok <- check_mutation_error(data["setCustomerTenants"]["error"]) do
      {:ok, :set}
    end
  end

  @doc """
  Updates the tier associated with a tenant.

  The `input` map must include `:tenant_identifier` and `:tier_identifier`.
  """
  @spec update_tier(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def update_tier(client, input) do
    variables = wrap_input(input)

    with {:ok, data} <- Client.execute(client, Operations.update_tenant_tier(), variables),
         :ok <- check_mutation_error(data["updateTenantTier"]["error"]) do
      {:ok, data["updateTenantTier"]["tenantTierMembership"]}
    end
  end
end
