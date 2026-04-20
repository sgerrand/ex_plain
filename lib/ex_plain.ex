defmodule ExPlain do
  @moduledoc """
  Elixir client for the [Plain GraphQL API](https://www.plain.com/docs/graphql/introduction).

  ## Getting started

      client = ExPlain.new(api_key: System.fetch_env!("PLAIN_API_KEY"))

      {:ok, customer} = ExPlain.Customers.get_by_email(client, "alice@example.com")
      {:ok, thread} = ExPlain.Threads.create(client, %{
        customer_identifier: %{customer_id: customer.id},
        title: "Cannot log in"
      })

  ## Pagination

  List operations follow the Relay cursor pagination convention. Pass `first:` and
  `after:` (or `last:` and `before:`) keyword options; the response is a map with
  `:nodes` and `:page_info`.

      {:ok, page} = ExPlain.Customers.list(client, first: 50)
      next_cursor = page.page_info.end_cursor
      {:ok, page2} = ExPlain.Customers.list(client, first: 50, after: next_cursor)

  ## Error handling

  All functions return `{:ok, result}` or `{:error, %ExPlain.Error{}}`. Mutation
  errors from the Plain API (validation failures, permission errors) are returned
  as `{:error, %ExPlain.Error{type: :mutation_error, ...}}` with field-level detail
  when available.

  ## Testing

  Pass a `plug:` option when creating a client to use `Req.Test` for HTTP stubbing
  without making real network calls:

      # In test_helper.exs:
      Req.Test.allow(MyApp.PlainTest, self())

      # In your test:
      client = ExPlain.new(api_key: "test_key", plug: {Req.Test, MyApp.PlainTest})
      Req.Test.stub(MyApp.PlainTest, fn conn ->
        Req.Test.json(conn, %{"data" => %{"customer" => nil}})
      end)

  """

  alias ExPlain.Client

  @default_base_url "https://core-api.uk.plain.com/graphql/v1"

  @doc """
  Creates a new `%ExPlain.Client{}`.

  ## Options

    * `:api_key` - required. Your Plain API key (e.g. `"plainApiKey_..."`).
    * `:base_url` - optional. API endpoint. Defaults to `#{@default_base_url}`.

  Any additional options are forwarded to `Req.new/1` (e.g. `plug:` for testing,
  `receive_timeout:` for request timeouts).
  """
  @spec new(keyword()) :: Client.t()
  def new(opts) do
    api_key = Keyword.fetch!(opts, :api_key)
    base_url = Keyword.get(opts, :base_url, @default_base_url)
    req_opts = Keyword.drop(opts, [:api_key, :base_url])
    Client.new(api_key, base_url, req_opts)
  end
end
