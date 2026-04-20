defmodule ExPlain.Labels do
  @moduledoc "Operations for managing label types in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Labels.LabelType

  import ExPlain.Util,
    only: [check_mutation_error: 1, build_pagination_vars: 1, camelize_keys: 1, put_if_set: 3]

  @doc """
  Returns a paginated list of label types.

  ## Options

  Pagination: `first:`, `after:`, `last:`, `before:`.
  Filtering: `filters:` (passed as a `LabelTypeFilter` input map).
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [LabelType.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables =
      build_pagination_vars(opts)
      |> put_if_set(:filters, opts[:filters])

    with {:ok, data} <- Client.execute(client, Operations.label_types(), variables) do
      conn = data["labelTypes"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> LabelType.from_map(e["node"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Fetches a label type by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, LabelType.t() | nil} | {:error, Error.t()}
  def get_by_id(client, label_type_id) do
    with {:ok, data} <-
           Client.execute(client, Operations.label_type_by_id(), %{labelTypeId: label_type_id}) do
      {:ok, LabelType.from_map(data["labelType"])}
    end
  end

  @doc """
  Creates a new label type.

  The `input` map must include `:name`. Optional: `:icon`, `:external_id`.
  """
  @spec create(Client.t(), map()) :: {:ok, LabelType.t()} | {:error, Error.t()}
  def create(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.create_label_type(), variables),
         :ok <- check_mutation_error(data["createLabelType"]["error"]) do
      {:ok, LabelType.from_map(data["createLabelType"]["labelType"])}
    end
  end

  @doc "Archives a label type."
  @spec archive(Client.t(), String.t()) :: {:ok, LabelType.t()} | {:error, Error.t()}
  def archive(client, label_type_id) do
    variables = %{input: %{labelTypeId: label_type_id}}

    with {:ok, data} <- Client.execute(client, Operations.archive_label_type(), variables),
         :ok <- check_mutation_error(data["archiveLabelType"]["error"]) do
      {:ok, LabelType.from_map(data["archiveLabelType"]["labelType"])}
    end
  end
end
