defmodule ExPlain.CustomerGroups do
  @moduledoc "Operations for managing customer groups in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.CustomerGroups.CustomerGroup

  import ExPlain.Util, only: [build_pagination_vars: 1, fetch_one: 5, list_connection: 5]

  @doc """
  Returns a paginated list of customer groups.

  ## Options

  Pagination: `first:`, `after:`, `last:`, `before:`.
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [CustomerGroup.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    list_connection(
      client,
      Operations.customer_groups(),
      variables,
      "customerGroups",
      &CustomerGroup.from_map/1
    )
  end

  @doc """
  Fetches a customer group by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) ::
          {:ok, CustomerGroup.t() | nil} | {:error, Error.t()}
  def get_by_id(client, customer_group_id) do
    fetch_one(
      client,
      Operations.customer_group_by_id(),
      %{customerGroupId: customer_group_id},
      "customerGroup",
      &CustomerGroup.from_map/1
    )
  end
end
