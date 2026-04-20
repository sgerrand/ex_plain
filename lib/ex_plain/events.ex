defmodule ExPlain.Events do
  @moduledoc "Operations for creating custom timeline events in Plain."

  alias ExPlain.{Client, Error, Operations}
  alias ExPlain.Events.{CustomerEvent, ThreadEvent}

  import ExPlain.Util, only: [check_mutation_error: 1, camelize_keys: 1]

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
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.create_customer_event(), variables),
         :ok <- check_mutation_error(data["createCustomerEvent"]["error"]) do
      {:ok, CustomerEvent.from_map(data["createCustomerEvent"]["customerEvent"])}
    end
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
    variables = %{input: camelize_keys(input)}

    with {:ok, data} <- Client.execute(client, Operations.create_thread_event(), variables),
         :ok <- check_mutation_error(data["createThreadEvent"]["error"]) do
      {:ok, ThreadEvent.from_map(data["createThreadEvent"]["threadEvent"])}
    end
  end
end
