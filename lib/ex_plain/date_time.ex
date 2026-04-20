defmodule ExPlain.DateTime do
  @moduledoc """
  A datetime as returned by the Plain API, available in both ISO 8601 and Unix
  timestamp formats.
  """

  @enforce_keys [:iso8601]
  defstruct [:iso8601, :unix_timestamp]

  @type t :: %__MODULE__{
          iso8601: String.t(),
          unix_timestamp: String.t() | nil
        }

  @doc false
  def from_map(nil), do: nil

  def from_map(%{"iso8601" => iso, "unixTimestamp" => unix}) do
    %__MODULE__{iso8601: iso, unix_timestamp: unix}
  end

  def from_map(%{"iso8601" => iso}) do
    %__MODULE__{iso8601: iso}
  end

  def from_map(map) when is_map(map) do
    raise ArgumentError, "unexpected datetime map (missing iso8601): #{inspect(map)}"
  end
end
