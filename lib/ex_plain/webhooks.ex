defmodule ExPlain.Webhooks do
  @moduledoc "Operations for managing webhook targets in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Webhooks.WebhookTarget

  import ExPlain.Util,
    only: [
      build_pagination_vars: 1,
      wrap_input: 1,
      fetch_one: 5,
      list_connection: 5,
      run_mutation: 5
    ]

  @doc "Returns a paginated list of webhook targets."
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [WebhookTarget.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables = build_pagination_vars(opts)

    list_connection(
      client,
      Operations.webhook_targets(),
      variables,
      "webhookTargets",
      &WebhookTarget.from_map/1
    )
  end

  @doc """
  Fetches a webhook target by its Plain ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) ::
          {:ok, WebhookTarget.t() | nil} | {:error, Error.t()}
  def get_by_id(client, webhook_target_id) do
    fetch_one(
      client,
      Operations.webhook_target_by_id(),
      %{webhookTargetId: webhook_target_id},
      "webhookTarget",
      &WebhookTarget.from_map/1
    )
  end

  @doc """
  Creates a new webhook target.

  The `input` map must include `:url` and `:event_subscriptions` (list of
  `%{event_type: "..."}` maps). Optional: `:description`, `:is_enabled`.
  """
  @spec create(Client.t(), map()) :: {:ok, WebhookTarget.t()} | {:error, Error.t()}
  def create(client, input) do
    run_mutation(
      client,
      Operations.create_webhook_target(),
      wrap_input(input),
      "createWebhookTarget",
      &WebhookTarget.from_map(&1["webhookTarget"])
    )
  end

  @doc "Updates a webhook target."
  @spec update(Client.t(), map()) :: {:ok, WebhookTarget.t()} | {:error, Error.t()}
  def update(client, input) do
    run_mutation(
      client,
      Operations.update_webhook_target(),
      wrap_input(input),
      "updateWebhookTarget",
      &WebhookTarget.from_map(&1["webhookTarget"])
    )
  end

  @doc "Deletes a webhook target."
  @spec delete(Client.t(), String.t()) :: {:ok, :deleted} | {:error, Error.t()}
  def delete(client, webhook_target_id) do
    variables = %{input: %{webhookTargetId: webhook_target_id}}

    run_mutation(
      client,
      Operations.delete_webhook_target(),
      variables,
      "deleteWebhookTarget",
      fn _ -> :deleted end
    )
  end
end
