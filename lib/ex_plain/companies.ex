defmodule ExPlain.Companies do
  @moduledoc "Operations for managing companies in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Companies.Company

  import ExPlain.Util,
    only: [
      build_pagination_vars: 1,
      camelize_keys: 1,
      wrap_input: 1,
      list_connection: 5,
      run_mutation: 5
    ]

  @doc """
  Returns a paginated list of companies.

  ## Options

  Pagination: `first:`, `after:`, `last:`, `before:`.
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [Company.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    list_connection(client, Operations.companies(), variables, "companies", &Company.from_map/1)
  end

  @doc """
  Searches companies by name or domain.

  The `search_query` map must include `:name` or `:domain_name`.
  """
  @spec search(Client.t(), map(), keyword()) ::
          {:ok, %{nodes: [Company.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def search(client, search_query, opts \\ []) do
    variables = build_pagination_vars(opts) |> Map.put(:searchQuery, camelize_keys(search_query))

    list_connection(
      client,
      Operations.search_companies(),
      variables,
      "searchCompanies",
      fn node ->
        Company.from_map(node["company"])
      end
    )
  end

  @doc """
  Creates or updates a company.

  The `input` map should include `:domain_name` as the identifier,
  and optionally `:name`.
  """
  @spec upsert(Client.t(), map()) :: {:ok, Company.t()} | {:error, Error.t()}
  def upsert(client, input) do
    run_mutation(
      client,
      Operations.upsert_company(),
      wrap_input(input),
      "upsertCompany",
      &Company.from_map(&1["company"])
    )
  end

  @doc """
  Updates the tier associated with a company.

  The `input` map must include `:company_identifier` and `:tier_identifier`.
  """
  @spec update_tier(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def update_tier(client, input) do
    run_mutation(
      client,
      Operations.update_company_tier(),
      wrap_input(input),
      "updateCompanyTier",
      & &1["companyTierMembership"]
    )
  end
end
