defmodule ExPlain.Util do
  @moduledoc false

  alias ExPlain.{Client, Error, PageInfo}

  @doc false
  def check_mutation_error(nil), do: :ok
  def check_mutation_error(error), do: {:error, Error.from_mutation_error(error)}

  @doc false
  def build_pagination_vars(opts) do
    %{}
    |> put_if_set(:first, opts[:first])
    |> put_if_set(:after, opts[:after])
    |> put_if_set(:last, opts[:last])
    |> put_if_set(:before, opts[:before])
  end

  @doc false
  def put_if_set(map, _key, nil), do: map
  def put_if_set(map, key, value), do: Map.put(map, key, value)

  @doc false
  def wrap_input(input), do: %{input: camelize_keys(input)}

  @doc false
  def camelize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_camel(k), camelize_keys(v)} end)
  end

  def camelize_keys(list) when is_list(list), do: Enum.map(list, &camelize_keys/1)
  def camelize_keys(value), do: value

  @doc """
  Fetches a single entity. Runs `document` and decodes `data[key]` with `decode`.
  """
  def fetch_one(client, document, variables, key, decode) do
    with {:ok, data} <- Client.execute(client, document, variables) do
      {:ok, decode.(data[key])}
    end
  end

  @doc """
  Runs a paginated query and decodes `data[key]` as a connection.

  Each edge node is passed to `decode`. Pass `total_count: true` to include the
  connection's `totalCount` in the result.
  """
  def list_connection(client, document, variables, key, decode, opts \\ []) do
    with {:ok, data} <- Client.execute(client, document, variables) do
      conn = data[key]

      result = %{
        nodes: Enum.map(conn["edges"] || [], fn e -> decode.(e["node"]) end),
        page_info: PageInfo.from_map(conn["pageInfo"])
      }

      result =
        if Keyword.get(opts, :total_count, false),
          do: Map.put(result, :total_count, conn["totalCount"]),
          else: result

      {:ok, result}
    end
  end

  @doc """
  Runs a mutation, checks `data[key]["error"]`, and on success decodes the
  payload with `decode` (which receives the `data[key]` map).
  """
  def run_mutation(client, document, variables, key, decode) do
    with {:ok, data} <- Client.execute(client, document, variables),
         payload = data[key],
         :ok <- check_mutation_error(payload["error"]) do
      {:ok, decode.(payload)}
    end
  end

  defp to_camel(key) when is_atom(key), do: key |> Atom.to_string() |> to_camel()

  defp to_camel(key) when is_binary(key) do
    [first | rest] = String.split(key, "_")
    first <> Enum.map_join(rest, &String.capitalize/1)
  end
end
