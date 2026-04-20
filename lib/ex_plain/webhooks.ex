defmodule ExPlain.Webhooks do
  @moduledoc "Operations for managing webhook targets in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}

  import ExPlain.Util, only: [check_mutation_error: 1, build_pagination_vars: 1, camelize_keys: 1]

  @doc "Returns a paginated list of webhook targets."
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [map()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    with {:ok, data} <- Client.execute(client, Operations.webhook_targets(), variables) do
      conn = data["webhookTargets"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> e["node"] end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Fetches a webhook target by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, map() | nil} | {:error, Error.t()}
  def get_by_id(client, webhook_target_id) do
    with {:ok, data} <-
           Client.execute(client, Operations.webhook_target_by_id(), %{
             webhookTargetId: webhook_target_id
           }) do
      {:ok, data["webhookTarget"]}
    end
  end

  @doc """
  Creates a new webhook target.

  The `input` map must include `:url` and `:event_subscriptions` (list of
  `%{event_type: "..."}` maps). Optional: `:description`, `:is_enabled`.
  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def create(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.create_webhook_target(), variables),
         :ok <- check_mutation_error(data["createWebhookTarget"]["error"]) do
      {:ok, data["createWebhookTarget"]["webhookTarget"]}
    end
  end

  @doc "Updates a webhook target."
  @spec update(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def update(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.update_webhook_target(), variables),
         :ok <- check_mutation_error(data["updateWebhookTarget"]["error"]) do
      {:ok, data["updateWebhookTarget"]["webhookTarget"]}
    end
  end

  @doc "Deletes a webhook target."
  @spec delete(Client.t(), String.t()) :: {:ok, :deleted} | {:error, Error.t()}
  def delete(client, webhook_target_id) do
    variables = %{input: %{webhookTargetId: webhook_target_id}}

    with {:ok, data} <- Client.execute(client, Operations.delete_webhook_target(), variables),
         :ok <- check_mutation_error(data["deleteWebhookTarget"]["error"]) do
      {:ok, :deleted}
    end
  end
end
