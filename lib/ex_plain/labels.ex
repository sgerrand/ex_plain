defmodule ExPlain.Labels do
  @moduledoc "Operations for managing label types in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Labels.LabelType

  import ExPlain.Util,
    only: [
      build_pagination_vars: 1,
      wrap_input: 1,
      put_if_set: 3,
      fetch_one: 5,
      list_connection: 5,
      run_mutation: 5
    ]

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

    list_connection(
      client,
      Operations.label_types(),
      variables,
      "labelTypes",
      &LabelType.from_map/1
    )
  end

  @doc """
  Fetches a label type by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, LabelType.t() | nil} | {:error, Error.t()}
  def get_by_id(client, label_type_id) do
    fetch_one(
      client,
      Operations.label_type_by_id(),
      %{labelTypeId: label_type_id},
      "labelType",
      &LabelType.from_map/1
    )
  end

  @doc """
  Creates a new label type.

  The `input` map must include `:name`. Optional: `:icon`, `:external_id`.
  """
  @spec create(Client.t(), map()) :: {:ok, LabelType.t()} | {:error, Error.t()}
  def create(client, input) do
    run_mutation(
      client,
      Operations.create_label_type(),
      wrap_input(input),
      "createLabelType",
      &LabelType.from_map(&1["labelType"])
    )
  end

  @doc "Archives a label type."
  @spec archive(Client.t(), String.t()) :: {:ok, LabelType.t()} | {:error, Error.t()}
  def archive(client, label_type_id) do
    variables = %{input: %{labelTypeId: label_type_id}}

    run_mutation(
      client,
      Operations.archive_label_type(),
      variables,
      "archiveLabelType",
      &LabelType.from_map(&1["labelType"])
    )
  end
end
