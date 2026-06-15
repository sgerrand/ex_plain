defmodule ExPlain.Customers do
  @moduledoc "Operations for managing customers in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Customers.Customer

  import ExPlain.Util,
    only: [
      build_pagination_vars: 1,
      wrap_input: 1,
      put_if_set: 3,
      fetch_one: 5,
      list_connection: 6,
      run_mutation: 5
    ]

  @doc """
  Returns a paginated list of customers.

  ## Options

  Pagination: `first:`, `after:`, `last:`, `before:`.
  Filtering: `filters:` (passed directly as a GraphQL `CustomersFilter` input map).
  Sorting: `sort_by:` (passed directly as a GraphQL `CustomersSort` input map).

  ## Example

      {:ok, page} = ExPlain.Customers.list(client, first: 50)
      customers = page.nodes
      next_cursor = page.page_info.end_cursor
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [Customer.t()], page_info: PageInfo.t(), total_count: integer()}}
          | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables =
      build_pagination_vars(opts)
      |> put_if_set(:filters, opts[:filters])
      |> put_if_set(:sortBy, opts[:sort_by])

    list_connection(client, Operations.customers(), variables, "customers", &Customer.from_map/1,
      total_count: true
    )
  end

  @doc """
  Fetches a customer by their Plain ID (e.g. `"c_01HX..."`).
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, Customer.t() | nil} | {:error, Error.t()}
  def get_by_id(client, customer_id) do
    fetch_one(
      client,
      Operations.customer_by_id(),
      %{customerId: customer_id},
      "customer",
      &Customer.from_map/1
    )
  end

  @doc """
  Fetches a customer by their email address.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_email(Client.t(), String.t()) :: {:ok, Customer.t() | nil} | {:error, Error.t()}
  def get_by_email(client, email) do
    fetch_one(
      client,
      Operations.customer_by_email(),
      %{email: email},
      "customerByEmail",
      &Customer.from_map/1
    )
  end

  @doc """
  Fetches a customer by their external ID (your system's identifier).
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_external_id(Client.t(), String.t()) ::
          {:ok, Customer.t() | nil} | {:error, Error.t()}
  def get_by_external_id(client, external_id) do
    fetch_one(
      client,
      Operations.customer_by_external_id(),
      %{externalId: external_id},
      "customerByExternalId",
      &Customer.from_map/1
    )
  end

  @doc """
  Creates or updates a customer (upsert).

  The `input` map must include:
    * `:identifier` — one of `:email_address`, `:customer_id`, or `:external_id`.
    * `:on_create` — fields to set on creation (required: `:email`, `:full_name`).
    * `:on_update` — fields to update if the customer already exists.

  Snake_case keys are automatically converted to camelCase before sending.

  ## Example

      ExPlain.Customers.upsert(client, %{
        identifier: %{email_address: %{email: "alice@example.com"}},
        on_create: %{email: %{email: "alice@example.com"}, full_name: "Alice"},
        on_update: %{full_name: %{value: "Alice Updated"}}
      })
  """
  @spec upsert(Client.t(), map()) ::
          {:ok, %{result: :created | :updated, customer: Customer.t()}} | {:error, Error.t()}
  def upsert(client, input) do
    run_mutation(
      client,
      Operations.upsert_customer(),
      wrap_input(input),
      "upsertCustomer",
      fn p ->
        %{result: decode_upsert_result(p["result"]), customer: Customer.from_map(p["customer"])}
      end
    )
  end

  @doc """
  Deletes a customer by ID.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, :deleted} | {:error, Error.t()}
  def delete(client, customer_id) do
    variables = %{input: %{customerId: customer_id}}

    run_mutation(client, Operations.delete_customer(), variables, "deleteCustomer", fn _ ->
      :deleted
    end)
  end

  @doc """
  Updates the company associated with a customer.

  The `input` map must include `:customer_id` and `:company_identifier`.
  `:company_identifier` is one of `%{company_id: id}` or `%{domain_name: domain}`.

  ## Example

      ExPlain.Customers.update_company(client, %{
        customer_id: "c_01HX...",
        company_identifier: %{domain_name: "example.com"}
      })
  """
  @spec update_company(Client.t(), map()) :: {:ok, Customer.t()} | {:error, Error.t()}
  def update_company(client, input) do
    run_mutation(
      client,
      Operations.update_customer_company(),
      wrap_input(input),
      "updateCustomerCompany",
      &Customer.from_map(&1["customer"])
    )
  end

  @doc """
  Adds a customer to one or more customer groups.

  ## Example

      ExPlain.Customers.add_to_customer_groups(client, %{
        customer_id: "c_01HX...",
        customer_group_identifiers: [%{customer_group_key: "enterprise"}]
      })
  """
  @spec add_to_customer_groups(Client.t(), map()) :: {:ok, list()} | {:error, Error.t()}
  def add_to_customer_groups(client, input) do
    run_mutation(
      client,
      Operations.add_customer_to_customer_groups(),
      wrap_input(input),
      "addCustomerToCustomerGroups",
      &(&1["customerGroupMemberships"] || [])
    )
  end

  @doc """
  Removes a customer from one or more customer groups.

  ## Example

      ExPlain.Customers.remove_from_customer_groups(client, %{
        customer_id: "c_01HX...",
        customer_group_identifiers: [%{customer_group_key: "enterprise"}]
      })
  """
  @spec remove_from_customer_groups(Client.t(), map()) :: {:ok, :removed} | {:error, Error.t()}
  def remove_from_customer_groups(client, input) do
    run_mutation(
      client,
      Operations.remove_customer_from_customer_groups(),
      wrap_input(input),
      "removeCustomerFromCustomerGroups",
      fn _ -> :removed end
    )
  end

  # ---------------------------------------------------------------------------

  defp decode_upsert_result("CREATED"), do: :created
  defp decode_upsert_result("UPDATED"), do: :updated

  defp decode_upsert_result(other),
    do: raise(ArgumentError, "unexpected upsert result: #{inspect(other)}")
end
