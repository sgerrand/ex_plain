defmodule ExPlain.Companies do
  @moduledoc "Operations for managing companies in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Companies.Company

  import ExPlain.Util, only: [check_mutation_error: 1, build_pagination_vars: 1, camelize_keys: 1]

  @doc """
  Returns a paginated list of companies.

  ## Options

  Pagination: `first:`, `after:`, `last:`, `before:`.
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [Company.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    with {:ok, data} <- Client.execute(client, Operations.companies(), variables) do
      conn = data["companies"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> Company.from_map(e["node"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Searches companies by name or domain.

  The `search_query` map must include `:name` or `:domain_name`.
  """
  @spec search(Client.t(), map(), keyword()) ::
          {:ok, %{nodes: [Company.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def search(client, search_query, opts \\ []) do
    variables = build_pagination_vars(opts) |> Map.put(:searchQuery, camelize_keys(search_query))

    with {:ok, data} <- Client.execute(client, Operations.search_companies(), variables) do
      conn = data["searchCompanies"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> Company.from_map(e["node"]["company"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Creates or updates a company.

  The `input` map should include `:domain_name` as the identifier,
  and optionally `:name`.
  """
  @spec upsert(Client.t(), map()) :: {:ok, Company.t()} | {:error, Error.t()}
  def upsert(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.upsert_company(), variables),
         :ok <- check_mutation_error(data["upsertCompany"]["error"]) do
      {:ok, Company.from_map(data["upsertCompany"]["company"])}
    end
  end

  @doc """
  Updates the tier associated with a company.

  The `input` map must include `:company_identifier` and `:tier_identifier`.
  """
  @spec update_tier(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def update_tier(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.update_company_tier(), variables),
         :ok <- check_mutation_error(data["updateCompanyTier"]["error"]) do
      {:ok, data["updateCompanyTier"]["companyTierMembership"]}
    end
  end
end
