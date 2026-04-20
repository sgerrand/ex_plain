defmodule ExPlain.Client do
  @moduledoc """
  Holds the configured HTTP client used to communicate with the Plain API.

  Create one with `ExPlain.new/1` and pass it as the first argument to every
  domain function.
  """

  @enforce_keys [:req]
  defstruct [:req]

  @type t :: %__MODULE__{req: Req.Request.t()}

  @spec new(String.t(), String.t(), keyword()) :: t()
  def new(api_key, base_url, extra_req_opts \\ []) do
    req =
      [
        url: base_url,
        headers: %{
          "content-type" => "application/json",
          "authorization" => "Bearer #{api_key}"
        }
      ]
      |> Keyword.merge(extra_req_opts)
      |> Req.new()

    %__MODULE__{req: req}
  end

  @spec execute(t(), String.t(), map()) :: {:ok, map()} | {:error, ExPlain.Error.t()}
  def execute(%__MODULE__{req: req}, document, variables \\ %{}) do
    body = %{query: document, variables: variables}

    case Req.post(req, json: body) do
      {:ok, %{status: status}} when status in [401, 403] ->
        {:error,
         ExPlain.Error.new(
           :forbidden,
           "Authentication failed. Please check the provided API key."
         )}

      {:ok, %{status: 400, body: body}} ->
        message =
          get_in(body, ["errors", Access.at(0), "message"]) ||
            "Malformed query, missing or invalid arguments."

        {:error, ExPlain.Error.new(:bad_request, message)}

      {:ok, %{status: 500}} ->
        {:error, ExPlain.Error.new(:internal_server_error, "Internal server error.")}

      {:ok, %{status: 200, body: %{"errors" => [%{"message" => message} | _]}}} ->
        {:error, ExPlain.Error.new(:graphql_error, message)}

      {:ok, %{status: 200, body: %{"data" => data}}} ->
        {:ok, data}

      {:error, exception} ->
        {:error, ExPlain.Error.new(:unknown, Exception.message(exception))}
    end
  end
end
