defmodule ExPlain.CustomerGroups do
  @moduledoc "Operations for managing customer groups in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.CustomerGroups.CustomerGroup

  import ExPlain.Util, only: [build_pagination_vars: 1]

  @doc """
  Returns a paginated list of customer groups.

  ## Options

  Pagination: `first:`, `after:`, `last:`, `before:`.
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [CustomerGroup.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    with {:ok, data} <- Client.execute(client, Operations.customer_groups(), variables) do
      conn = data["customerGroups"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> CustomerGroup.from_map(e["node"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Fetches a customer group by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) ::
          {:ok, CustomerGroup.t() | nil} | {:error, Error.t()}
  def get_by_id(client, customer_group_id) do
    with {:ok, data} <-
           Client.execute(client, Operations.customer_group_by_id(), %{
             customerGroupId: customer_group_id
           }) do
      {:ok, CustomerGroup.from_map(data["customerGroup"])}
    end
  end
end
