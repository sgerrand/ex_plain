# ExPlain

An Elixir client for the [Plain GraphQL API](https://www.plain.com/docs/graphql/introduction).

## Installation

Add `ex_plain` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_plain, "~> 0.1.0"}
  ]
end
```

## Quick start

```elixir
client = ExPlain.new(api_key: System.fetch_env!("PLAIN_API_KEY"))

# Look up a customer
{:ok, customer} = ExPlain.Customers.get_by_email(client, "alice@example.com")

# Create a thread
{:ok, thread} = ExPlain.Threads.create(client, %{
  customer_identifier: %{customer_id: customer.id},
  title: "Cannot log in"
})
```

## Domains covered

| Module | Operations |
| ------ | ---------- |
| `ExPlain.Customers` | upsert, get, list, delete, manage groups |
| `ExPlain.Threads` | create, assign, label, reply, change status |
| `ExPlain.Companies` | upsert, get, list |
| `ExPlain.Tenants` | upsert, get, list, manage customers |
| `ExPlain.Tiers` | upsert, get, list |
| `ExPlain.Labels` | list label types, add/remove labels on threads |
| `ExPlain.Events` | create customer and thread timeline events |
| `ExPlain.Users` | list users, get current user |
| `ExPlain.Webhooks` | list, create, update, delete webhook targets |

## Pagination

List operations follow the Relay cursor pagination convention. Pass `first:` and
`after:` (or `last:` and `before:`) keyword options; the response is a map with
`:nodes` and `:page_info`.

```elixir
{:ok, page} = ExPlain.Customers.list(client, first: 50)
next_cursor = page.page_info.end_cursor
{:ok, page2} = ExPlain.Customers.list(client, first: 50, after: next_cursor)
```

## Error handling

All functions return `{:ok, result}` or `{:error, %ExPlain.Error{}}`. Mutation
errors from Plain (validation failures, permission errors) come back as
`{:error, %ExPlain.Error{type: :mutation_error}}` with field-level detail when
available.

```elixir
case ExPlain.Customers.upsert(client, input) do
  {:ok, %{result: :created, customer: customer}} -> customer
  {:error, %ExPlain.Error{type: :mutation_error, message: msg}} -> {:error, msg}
  {:error, %ExPlain.Error{type: :forbidden}} -> {:error, :unauthorized}
end
```

## Testing

Pass a `plug:` option to use `Req.Test` for HTTP stubbing without real network calls:

```elixir
client = ExPlain.new(api_key: "test_key", plug: {Req.Test, __MODULE__})

Req.Test.stub(__MODULE__, fn conn ->
  Req.Test.json(conn, %{"data" => %{"customer" => %{"id" => "c_01", ...}}})
end)
```

## Documentation

Full API documentation is available on [HexDocs](https://hexdocs.pm/ex_plain).
