defmodule ExPlain.Util do
  @moduledoc false

  alias ExPlain.Error

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
  def camelize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_camel(k), camelize_keys(v)} end)
  end

  def camelize_keys(list) when is_list(list), do: Enum.map(list, &camelize_keys/1)
  def camelize_keys(value), do: value

  defp to_camel(key) when is_atom(key), do: key |> Atom.to_string() |> to_camel()

  defp to_camel(key) when is_binary(key) do
    case String.split(key, "_") do
      [single] -> single
      [first | rest] -> first <> Enum.map_join(rest, &String.capitalize/1)
    end
  end
end
