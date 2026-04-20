# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

`ex_plain` is an Elixir client library for the [Plain GraphQL API](https://www.plain.com/docs/graphql/introduction).

Dependency: `{:req, "~> 0.5"}` (pulls in `jason` and `finch` transitively). Test-only: `{:plug, "~> 1.0"}` (needed for `Req.Test`).

## Commands

```bash
mix deps.get           # Install dependencies
mix test               # Run all tests
mix test test/ex_plain/customers_test.exs        # Single test file
mix test test/ex_plain/customers_test.exs:11     # Single test by line
mix format             # Auto-format
mix format --check-formatted   # Format check (used in CI)
mix docs               # Generate ExDoc
```

Elixir 1.19.4-otp-28 / Erlang 28.4 (via `.tool-versions`).

## Architecture

### Entry point

`ExPlain.new(api_key: "...")` returns `%ExPlain.Client{}`. The client is passed as the first argument to every domain function — this supports multiple simultaneous clients (multi-tenant, test vs. prod).

### Request execution

`ExPlain.Client.execute/3` makes a POST to `https://core-api.uk.plain.com/graphql/v1` and returns `{:ok, data_map} | {:error, %ExPlain.Error{}}`. All HTTP and GraphQL-level errors are normalized here.

### GraphQL operations

`ExPlain.Operations` holds all query/mutation document strings as `@doc false` functions. Field selections are composed from shared module attributes (e.g. `@customer_fields`, `@thread_fields`) using compile-time string interpolation — no runtime fragment assembly.

### Domain modules

Eight domain modules, each following the same pattern:

| Module | Struct |
| ------ | ------ |
| `ExPlain.Customers` | `ExPlain.Customers.Customer` |
| `ExPlain.Threads` | `ExPlain.Threads.Thread` |
| `ExPlain.Companies` | `ExPlain.Companies.Company` |
| `ExPlain.Tenants` | `ExPlain.Tenants.Tenant` |
| `ExPlain.Tiers` | `ExPlain.Tiers.Tier` |
| `ExPlain.Labels` | `ExPlain.Labels.LabelType`, `ExPlain.Labels.Label` |
| `ExPlain.Events` | `ExPlain.Events.CustomerEvent`, `ExPlain.Events.ThreadEvent` |
| `ExPlain.Users` | `ExPlain.Users.User` |
| `ExPlain.Webhooks` | raw maps (no struct yet) |

All return `{:ok, result} | {:error, %ExPlain.Error{}}`.

### Shared utilities

- `ExPlain.Util` — `camelize_keys/1` (snake_case → camelCase for GraphQL variables), `build_pagination_vars/1`, `check_mutation_error/1`, `put_if_set/3`.
- `ExPlain.Actor` — decodes GraphQL union `Actor` (UserActor | CustomerActor | SystemActor | MachineUserActor | DeletedCustomerActor).
- `ExPlain.PageInfo`, `ExPlain.DateTime`, `ExPlain.Error` — shared types.
- `ExPlain.Components` — builders for `ComponentInput` maps used in thread/event mutations.

### Input convention

All domain functions accept snake_case atom-keyed maps. `camelize_keys/1` recursively converts them to camelCase string keys before sending as GraphQL variables.

### Error handling

Mutation errors from Plain (`data.mutationName.error`) are checked in each domain function via `check_mutation_error/1` and returned as `{:error, %ExPlain.Error{type: :mutation_error}}`.

### Testing

`Req.Test` is used for network stubbing. Pass `plug: {Req.Test, MyStubName}` when constructing the client. See `test/ex_plain/customers_test.exs` for the pattern.

### TypeScript SDK reference

A local clone of the official TypeScript SDK is at `tmp/team-plain/typescript-sdk/`. The `src/graphql/` directory contains authoritative fragment files (`.gql`) and a generated `types.ts`. Consult these when adding new operations or updating field selections to match the official API surface.
