defmodule ExPlain.Users do
  @moduledoc "Operations for fetching workspace users (agents) in Plain."

  alias ExPlain.{Client, Error, Operations}
  alias ExPlain.Users.User

  import ExPlain.Util, only: [fetch_one: 5]

  @doc """
  Fetches a workspace user by their Plain user ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, User.t() | nil} | {:error, Error.t()}
  def get_by_id(client, user_id) do
    fetch_one(client, Operations.user_by_id(), %{userId: user_id}, "userById", &User.from_map/1)
  end

  @doc """
  Fetches a workspace user by their email address.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_email(Client.t(), String.t()) :: {:ok, User.t() | nil} | {:error, Error.t()}
  def get_by_email(client, email) do
    fetch_one(
      client,
      Operations.user_by_email(),
      %{email: email},
      "userByEmail",
      &User.from_map/1
    )
  end
end
