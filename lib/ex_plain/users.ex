defmodule ExPlain.Users do
  @moduledoc "Operations for fetching workspace users (agents) in Plain."

  alias ExPlain.{Client, Error, Operations}
  alias ExPlain.Users.User

  @doc """
  Fetches a workspace user by their Plain user ID.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_id(Client.t(), String.t()) :: {:ok, User.t() | nil} | {:error, Error.t()}
  def get_by_id(client, user_id) do
    with {:ok, data} <- Client.execute(client, Operations.user_by_id(), %{userId: user_id}) do
      {:ok, User.from_map(data["userById"])}
    end
  end

  @doc """
  Fetches a workspace user by their email address.
  Returns `{:ok, nil}` if not found.
  """
  @spec get_by_email(Client.t(), String.t()) :: {:ok, User.t() | nil} | {:error, Error.t()}
  def get_by_email(client, email) do
    with {:ok, data} <- Client.execute(client, Operations.user_by_email(), %{email: email}) do
      {:ok, User.from_map(data["userByEmail"])}
    end
  end
end
