defmodule ExPlain.Error do
  @moduledoc """
  Represents an error returned by the Plain API or during client execution.

  The `:type` field indicates the error category:

    * `:mutation_error` — a Plain API mutation returned an application-level error.
      Check `:code`, `:message`, and `:fields` for details.
    * `:forbidden` — authentication or authorization failed.
    * `:bad_request` — the request was malformed.
    * `:internal_server_error` — the Plain API returned a 500.
    * `:graphql_error` — the response contained a GraphQL error outside a mutation.
    * `:unknown` — an unexpected client-side error occurred.
  """

  @enforce_keys [:type, :message]
  defstruct [:type, :message, :code, :fields]

  @type error_type ::
          :mutation_error
          | :forbidden
          | :bad_request
          | :internal_server_error
          | :graphql_error
          | :unknown

  @type field_error :: %{
          required(:field) => String.t(),
          required(:message) => String.t(),
          required(:type) => :not_found | :required | :validation
        }

  @type t :: %__MODULE__{
          type: error_type(),
          message: String.t(),
          code: String.t() | nil,
          fields: [field_error()] | nil
        }

  @doc false
  def new(type, message) do
    %__MODULE__{type: type, message: message}
  end

  @doc false
  def from_mutation_error(%{
        "message" => message,
        "type" => _type,
        "code" => code,
        "fields" => fields
      }) do
    field_errors =
      Enum.map(fields, fn %{"field" => f, "message" => m, "type" => t} ->
        %{field: f, message: m, type: decode_field_error_type(t)}
      end)

    %__MODULE__{
      type: :mutation_error,
      message: message,
      code: code,
      fields: field_errors
    }
  end

  defp decode_field_error_type("NOT_FOUND"), do: :not_found
  defp decode_field_error_type("REQUIRED"), do: :required
  defp decode_field_error_type(_), do: :validation
end
