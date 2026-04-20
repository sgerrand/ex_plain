defmodule ExPlain.PageInfo do
  @moduledoc """
  Relay-style cursor pagination info included in all list responses.

  Use `end_cursor` with `after:` to fetch the next page, and
  check `has_next_page` to know whether more results exist.
  """

  @enforce_keys [:has_next_page, :has_previous_page]
  defstruct [:start_cursor, :end_cursor, :has_next_page, :has_previous_page]

  @type t :: %__MODULE__{
          start_cursor: String.t() | nil,
          end_cursor: String.t() | nil,
          has_next_page: boolean(),
          has_previous_page: boolean()
        }

  @doc false
  def from_map(%{
        "hasNextPage" => hnp,
        "hasPreviousPage" => hpp,
        "startCursor" => sc,
        "endCursor" => ec
      }) do
    %__MODULE__{
      has_next_page: hnp,
      has_previous_page: hpp,
      start_cursor: sc,
      end_cursor: ec
    }
  end
end
