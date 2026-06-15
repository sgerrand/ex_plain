defmodule ExPlain.Threads do
  @moduledoc "Operations for managing threads in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Labels.Label
  alias ExPlain.Threads.Thread

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
  Returns a paginated list of threads.

  ## Options

  Pagination: `first:`, `after:`, `last:`, `before:`.
  Filtering: `filters:` (passed as a `ThreadsFilter` input map).
  Sorting: `sort_by:` (passed as a `ThreadsSort` input map).
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, %{nodes: [Thread.t()], page_info: PageInfo.t()}} | {:error, Error.t()}
  def list(client, opts \\ []) do
    variables =
      build_pagination_vars(opts)
      |> put_if_set(:filters, opts[:filters])
      |> put_if_set(:sortBy, opts[:sort_by])

    list_connection(client, Operations.threads(), variables, "threads", &Thread.from_map/1)
  end

  @doc """
  Fetches a thread by its Plain ID (e.g. `"th_01HX..."`).
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, Thread.t() | nil} | {:error, Error.t()}
  def get_by_id(client, thread_id) do
    fetch_one(
      client,
      Operations.thread_by_id(),
      %{threadId: thread_id},
      "thread",
      &Thread.from_map/1
    )
  end

  @doc """
  Fetches a thread by its human-readable ref (e.g. `"T-1234"`).
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_ref(Client.t(), String.t()) :: {:ok, Thread.t() | nil} | {:error, Error.t()}
  def get_by_ref(client, ref) do
    fetch_one(client, Operations.thread_by_ref(), %{ref: ref}, "threadByRef", &Thread.from_map/1)
  end

  @doc """
  Fetches a thread by its external ID. External IDs are unique per customer,
  so the customer ID is also required.

  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_external_id(Client.t(), String.t(), String.t()) ::
          {:ok, Thread.t() | nil} | {:error, Error.t()}
  def get_by_external_id(client, customer_id, external_id) do
    variables = %{customerId: customer_id, externalId: external_id}

    fetch_one(
      client,
      Operations.thread_by_external_id(),
      variables,
      "threadByExternalId",
      &Thread.from_map/1
    )
  end

  @doc """
  Creates a new thread.

  The `input` map must include `:customer_identifier` with one of:
  `:customer_id`, `:customer_external_id`, or `:email_address`.

  Optional fields: `:title`, `:description`, `:priority` (0–3), `:channel`,
  `:label_type_ids`, `:tenant_identifier`, `:external_id`.

  ## Example

      ExPlain.Threads.create(client, %{
        customer_identifier: %{customer_id: "c_01HX..."},
        title: "Cannot log in",
        priority: 1
      })
  """
  @spec create(Client.t(), map()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def create(client, input) do
    run_mutation(
      client,
      Operations.create_thread(),
      wrap_input(input),
      "createThread",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc """
  Assigns a thread to a user or machine user.

  Pass either `user_id:` or `machine_user_id:` in opts.

  ## Example

      ExPlain.Threads.assign(client, "th_01HX...", user_id: "usr_01HX...")
  """
  @spec assign(Client.t(), String.t(), keyword()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def assign(client, thread_id, opts) do
    input =
      %{threadId: thread_id}
      |> put_if_set(:userId, opts[:user_id])
      |> put_if_set(:machineUserId, opts[:machine_user_id])

    variables = %{input: input}

    run_mutation(
      client,
      Operations.assign_thread(),
      variables,
      "assignThread",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc "Unassigns a thread."
  @spec unassign(Client.t(), String.t()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def unassign(client, thread_id) do
    variables = %{input: %{threadId: thread_id}}

    run_mutation(
      client,
      Operations.unassign_thread(),
      variables,
      "unassignThread",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc """
  Changes a thread's priority.

  Valid priorities are 0 (urgent), 1 (high), 2 (normal), 3 (low).
  """
  @spec change_priority(Client.t(), String.t(), integer()) ::
          {:ok, Thread.t()} | {:error, Error.t()}
  def change_priority(client, thread_id, priority) do
    variables = %{input: %{threadId: thread_id, priority: priority}}

    run_mutation(
      client,
      Operations.change_thread_priority(),
      variables,
      "changeThreadPriority",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc "Updates the tenant associated with a thread."
  @spec update_tenant(Client.t(), map()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def update_tenant(client, input) do
    run_mutation(
      client,
      Operations.update_thread_tenant(),
      wrap_input(input),
      "updateThreadTenant",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc "Marks a thread as done."
  @spec mark_as_done(Client.t(), String.t()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def mark_as_done(client, thread_id) do
    variables = %{input: %{threadId: thread_id}}

    run_mutation(
      client,
      Operations.mark_thread_as_done(),
      variables,
      "markThreadAsDone",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc """
  Snoozes a thread for a given number of seconds.
  """
  @spec snooze(Client.t(), String.t(), integer()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def snooze(client, thread_id, snooze_until_seconds) do
    variables = %{input: %{threadId: thread_id, snoozeUntilSeconds: snooze_until_seconds}}

    run_mutation(
      client,
      Operations.snooze_thread(),
      variables,
      "snoozeThread",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc "Marks a thread as todo (e.g. unsnoozes it)."
  @spec mark_as_todo(Client.t(), String.t()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def mark_as_todo(client, thread_id) do
    variables = %{input: %{threadId: thread_id}}

    run_mutation(
      client,
      Operations.mark_thread_as_todo(),
      variables,
      "markThreadAsTodo",
      &Thread.from_map(&1["thread"])
    )
  end

  @doc """
  Replies to a thread via the API channel.

  The `input` map must include `:thread_id` and `:components`.
  """
  @spec reply(Client.t(), map()) :: {:ok, :sent} | {:error, Error.t()}
  def reply(client, input) do
    run_mutation(client, Operations.reply_to_thread(), wrap_input(input), "replyToThread", fn _ ->
      :sent
    end)
  end

  @doc """
  Sends a chat message on a thread (agent → customer).

  The `input` map must include `:thread_id` and one of `:text` or `:attachment_ids`.
  """
  @spec send_chat(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def send_chat(client, input) do
    run_mutation(client, Operations.send_chat(), wrap_input(input), "sendChat", & &1["chat"])
  end

  @doc """
  Sends a chat message as the customer (backfill inbound chat).

  The `input` map must include `:thread_id` and one of `:text` or `:attachment_ids`.
  """
  @spec send_customer_chat(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def send_customer_chat(client, input) do
    run_mutation(
      client,
      Operations.send_customer_chat(),
      wrap_input(input),
      "sendCustomerChat",
      & &1["chat"]
    )
  end

  @doc """
  Sends a new outbound email on a thread.

  The `input` map must include `:thread_id` and `:components`.
  """
  @spec send_email(Client.t(), map()) :: {:ok, :sent} | {:error, Error.t()}
  def send_email(client, input) do
    run_mutation(client, Operations.send_new_email(), wrap_input(input), "sendNewEmail", fn _ ->
      :sent
    end)
  end

  @doc """
  Replies to an email on a thread.

  The `input` map must include `:email_id` and `:components`.
  """
  @spec reply_to_email(Client.t(), map()) :: {:ok, :sent} | {:error, Error.t()}
  def reply_to_email(client, input) do
    run_mutation(client, Operations.reply_to_email(), wrap_input(input), "replyToEmail", fn _ ->
      :sent
    end)
  end

  @doc """
  Creates a note on a thread (internal, not visible to the customer).

  The `input` map must include `:thread_id` and `:markdown`.
  """
  @spec create_note(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def create_note(client, input) do
    run_mutation(client, Operations.create_note(), wrap_input(input), "createNote", & &1["note"])
  end

  @doc """
  Adds labels to a thread.

  ## Example

      ExPlain.Threads.add_labels(client, "th_01HX...", ["lbt_01HX...", "lbt_02HX..."])
  """
  @spec add_labels(Client.t(), String.t(), [String.t()]) ::
          {:ok, [ExPlain.Labels.Label.t()]} | {:error, Error.t()}
  def add_labels(client, thread_id, label_type_ids) do
    variables = %{input: %{threadId: thread_id, labelTypeIds: label_type_ids}}

    run_mutation(client, Operations.add_labels(), variables, "addLabels", fn p ->
      Enum.map(p["labels"] || [], &Label.from_map/1)
    end)
  end

  @doc """
  Removes labels from a thread.

  ## Example

      ExPlain.Threads.remove_labels(client, ["lbl_01HX...", "lbl_02HX..."])
  """
  @spec remove_labels(Client.t(), [String.t()]) :: {:ok, :removed} | {:error, Error.t()}
  def remove_labels(client, label_ids) do
    variables = %{input: %{labelIds: label_ids}}

    run_mutation(client, Operations.remove_labels(), variables, "removeLabels", fn _ ->
      :removed
    end)
  end

  @doc """
  Upserts a custom thread field.

  The `input` map must include `:thread_id`, `:key`, `:type`, and either
  `:string_value` or `:boolean_value`.
  """
  @spec upsert_field(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def upsert_field(client, input) do
    run_mutation(
      client,
      Operations.upsert_thread_field(),
      wrap_input(input),
      "upsertThreadField",
      & &1["threadField"]
    )
  end

  @doc "Deletes a custom thread field."
  @spec delete_field(Client.t(), String.t()) :: {:ok, :deleted} | {:error, Error.t()}
  def delete_field(client, thread_field_id) do
    variables = %{input: %{threadFieldId: thread_field_id}}

    run_mutation(client, Operations.delete_thread_field(), variables, "deleteThreadField", fn _ ->
      :deleted
    end)
  end
end
