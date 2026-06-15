defmodule ExPlain.Events do
  @moduledoc "Operations for creating custom timeline events in Plain."

  alias ExPlain.{Client, Error, Operations}
  alias ExPlain.Events.{CustomerEvent, ThreadEvent}

  import ExPlain.Util, only: [wrap_input: 1, run_mutation: 5]

  @doc """
  Creates a custom event on a customer's timeline.

  The `input` map must include `:customer_identifier`, `:title`, and `:components`.

  ## Example

      ExPlain.Events.create_customer_event(client, %{
        customer_identifier: %{customer_id: "c_01HX..."},
        title: "Subscription upgraded",
        components: [ExPlain.Components.text("Upgraded from Free to Pro")]
      })
  """
  @spec create_customer_event(Client.t(), map()) :: {:ok, CustomerEvent.t()} | {:error, Error.t()}
  def create_customer_event(client, input) do
    run_mutation(
      client,
      Operations.create_customer_event(),
      wrap_input(input),
      "createCustomerEvent",
      &CustomerEvent.from_map(&1["customerEvent"])
    )
  end

  @doc """
  Creates a custom event on a thread's timeline.

  The `input` map must include `:thread_id`, `:title`, and `:components`.

  ## Example

      ExPlain.Events.create_thread_event(client, %{
        thread_id: "th_01HX...",
        title: "Webhook sent",
        components: [ExPlain.Components.text("Payload delivered to https://example.com")]
      })
  """
  @spec create_thread_event(Client.t(), map()) :: {:ok, ThreadEvent.t()} | {:error, Error.t()}
  def create_thread_event(client, input) do
    run_mutation(
      client,
      Operations.create_thread_event(),
      wrap_input(input),
      "createThreadEvent",
      &ThreadEvent.from_map(&1["threadEvent"])
    )
  end
end
