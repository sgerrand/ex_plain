defmodule ExPlain.Threads do
  @moduledoc "Operations for managing threads in Plain."

  alias ExPlain.{Client, Error, Operations, PageInfo}
  alias ExPlain.Labels.Label
  alias ExPlain.Threads.Thread

  import ExPlain.Util,
    only: [check_mutation_error: 1, build_pagination_vars: 1, camelize_keys: 1, put_if_set: 3]

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

    with {:ok, data} <- Client.execute(client, Operations.threads(), variables) do
      conn = data["threads"]

      {:ok,
       %{
         nodes: Enum.map(conn["edges"], fn e -> Thread.from_map(e["node"]) end),
         page_info: PageInfo.from_map(conn["pageInfo"])
       }}
    end
  end

  @doc """
  Fetches a thread by its Plain ID (e.g. `"th_01HX..."`).
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, Thread.t() | nil} | {:error, Error.t()}
  def get_by_id(client, thread_id) do
    with {:ok, data} <- Client.execute(client, Operations.thread_by_id(), %{threadId: thread_id}) do
      {:ok, Thread.from_map(data["thread"])}
    end
  end

  @doc """
  Fetches a thread by its human-readable ref (e.g. `"T-1234"`).
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_ref(Client.t(), String.t()) :: {:ok, Thread.t() | nil} | {:error, Error.t()}
  def get_by_ref(client, ref) do
    with {:ok, data} <- Client.execute(client, Operations.thread_by_ref(), %{ref: ref}) do
      {:ok, Thread.from_map(data["threadByRef"])}
    end
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

    with {:ok, data} <- Client.execute(client, Operations.thread_by_external_id(), variables) do
      {:ok, Thread.from_map(data["threadByExternalId"])}
    end
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
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.create_thread(), variables),
         :ok <- check_mutation_error(data["createThread"]["error"]) do
      {:ok, Thread.from_map(data["createThread"]["thread"])}
    end
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

    with {:ok, data} <- Client.execute(client, Operations.assign_thread(), variables),
         :ok <- check_mutation_error(data["assignThread"]["error"]) do
      {:ok, Thread.from_map(data["assignThread"]["thread"])}
    end
  end

  @doc "Unassigns a thread."
  @spec unassign(Client.t(), String.t()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def unassign(client, thread_id) do
    variables = %{input: %{threadId: thread_id}}

    with {:ok, data} <- Client.execute(client, Operations.unassign_thread(), variables),
         :ok <- check_mutation_error(data["unassignThread"]["error"]) do
      {:ok, Thread.from_map(data["unassignThread"]["thread"])}
    end
  end

  @doc """
  Changes a thread's priority.

  Valid priorities are 0 (urgent), 1 (high), 2 (normal), 3 (low).
  """
  @spec change_priority(Client.t(), String.t(), integer()) ::
          {:ok, Thread.t()} | {:error, Error.t()}
  def change_priority(client, thread_id, priority) do
    variables = %{input: %{threadId: thread_id, priority: priority}}

    with {:ok, data} <- Client.execute(client, Operations.change_thread_priority(), variables),
         :ok <- check_mutation_error(data["changeThreadPriority"]["error"]) do
      {:ok, Thread.from_map(data["changeThreadPriority"]["thread"])}
    end
  end

  @doc "Updates the tenant associated with a thread."
  @spec update_tenant(Client.t(), map()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def update_tenant(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.update_thread_tenant(), variables),
         :ok <- check_mutation_error(data["updateThreadTenant"]["error"]) do
      {:ok, Thread.from_map(data["updateThreadTenant"]["thread"])}
    end
  end

  @doc "Marks a thread as done."
  @spec mark_as_done(Client.t(), String.t()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def mark_as_done(client, thread_id) do
    variables = %{input: %{threadId: thread_id}}

    with {:ok, data} <- Client.execute(client, Operations.mark_thread_as_done(), variables),
         :ok <- check_mutation_error(data["markThreadAsDone"]["error"]) do
      {:ok, Thread.from_map(data["markThreadAsDone"]["thread"])}
    end
  end

  @doc """
  Snoozes a thread for a given number of seconds.
  """
  @spec snooze(Client.t(), String.t(), integer()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def snooze(client, thread_id, snooze_until_seconds) do
    variables = %{input: %{threadId: thread_id, snoozeUntilSeconds: snooze_until_seconds}}

    with {:ok, data} <- Client.execute(client, Operations.snooze_thread(), variables),
         :ok <- check_mutation_error(data["snoozeThread"]["error"]) do
      {:ok, Thread.from_map(data["snoozeThread"]["thread"])}
    end
  end

  @doc "Marks a thread as todo (e.g. unsnoozes it)."
  @spec mark_as_todo(Client.t(), String.t()) :: {:ok, Thread.t()} | {:error, Error.t()}
  def mark_as_todo(client, thread_id) do
    variables = %{input: %{threadId: thread_id}}

    with {:ok, data} <- Client.execute(client, Operations.mark_thread_as_todo(), variables),
         :ok <- check_mutation_error(data["markThreadAsTodo"]["error"]) do
      {:ok, Thread.from_map(data["markThreadAsTodo"]["thread"])}
    end
  end

  @doc """
  Replies to a thread via the API channel.

  The `input` map must include `:thread_id` and `:components`.
  """
  @spec reply(Client.t(), map()) :: {:ok, :sent} | {:error, Error.t()}
  def reply(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.reply_to_thread(), variables),
         :ok <- check_mutation_error(data["replyToThread"]["error"]) do
      {:ok, :sent}
    end
  end

  @doc """
  Sends a chat message on a thread (agent → customer).

  The `input` map must include `:thread_id` and one of `:text` or `:attachment_ids`.
  """
  @spec send_chat(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def send_chat(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.send_chat(), variables),
         :ok <- check_mutation_error(data["sendChat"]["error"]) do
      {:ok, data["sendChat"]["chat"]}
    end
  end

  @doc """
  Sends a chat message as the customer (backfill inbound chat).

  The `input` map must include `:thread_id` and one of `:text` or `:attachment_ids`.
  """
  @spec send_customer_chat(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def send_customer_chat(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.send_customer_chat(), variables),
         :ok <- check_mutation_error(data["sendCustomerChat"]["error"]) do
      {:ok, data["sendCustomerChat"]["chat"]}
    end
  end

  @doc """
  Sends a new outbound email on a thread.

  The `input` map must include `:thread_id` and `:components`.
  """
  @spec send_email(Client.t(), map()) :: {:ok, :sent} | {:error, Error.t()}
  def send_email(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.send_new_email(), variables),
         :ok <- check_mutation_error(data["sendNewEmail"]["error"]) do
      {:ok, :sent}
    end
  end

  @doc """
  Replies to an email on a thread.

  The `input` map must include `:email_id` and `:components`.
  """
  @spec reply_to_email(Client.t(), map()) :: {:ok, :sent} | {:error, Error.t()}
  def reply_to_email(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.reply_to_email(), variables),
         :ok <- check_mutation_error(data["replyToEmail"]["error"]) do
      {:ok, :sent}
    end
  end

  @doc """
  Creates a note on a thread (internal, not visible to the customer).

  The `input` map must include `:thread_id` and `:markdown`.
  """
  @spec create_note(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def create_note(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.create_note(), variables),
         :ok <- check_mutation_error(data["createNote"]["error"]) do
      {:ok, data["createNote"]["note"]}
    end
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

    with {:ok, data} <- Client.execute(client, Operations.add_labels(), variables),
         :ok <- check_mutation_error(data["addLabels"]["error"]) do
      labels = Enum.map(data["addLabels"]["labels"] || [], &Label.from_map/1)
      {:ok, labels}
    end
  end

  @doc """
  Removes labels from a thread.

  ## Example

      ExPlain.Threads.remove_labels(client, ["lbl_01HX...", "lbl_02HX..."])
  """
  @spec remove_labels(Client.t(), [String.t()]) :: {:ok, :removed} | {:error, Error.t()}
  def remove_labels(client, label_ids) do
    variables = %{input: %{labelIds: label_ids}}

    with {:ok, data} <- Client.execute(client, Operations.remove_labels(), variables),
         :ok <- check_mutation_error(data["removeLabels"]["error"]) do
      {:ok, :removed}
    end
  end

  @doc """
  Upserts a custom thread field.

  The `input` map must include `:thread_id`, `:key`, `:type`, and either
  `:string_value` or `:boolean_value`.
  """
  @spec upsert_field(Client.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def upsert_field(client, input) do
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.upsert_thread_field(), variables),
         :ok <- check_mutation_error(data["upsertThreadField"]["error"]) do
      {:ok, data["upsertThreadField"]["threadField"]}
    end
  end

  @doc "Deletes a custom thread field."
  @spec delete_field(Client.t(), String.t()) :: {:ok, :deleted} | {:error, Error.t()}
  def delete_field(client, thread_field_id) do
    variables = %{input: %{threadFieldId: thread_field_id}}

    with {:ok, data} <- Client.execute(client, Operations.delete_thread_field(), variables),
         :ok <- check_mutation_error(data["deleteThreadField"]["error"]) do
      {:ok, :deleted}
    end
  end
end
