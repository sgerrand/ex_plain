defmodule ExPlain.UsersTest do
  use ExUnit.Case, async: true

  alias ExPlain.Users.User

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "get_by_id/2" do
    test "returns user when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"userById" => user_fixture()}})
      end)

      assert {:ok, %User{id: "usr_01"}} =
               ExPlain.Users.get_by_id(stub_client(__MODULE__), "usr_01")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"userById" => nil}})
      end)

      assert {:ok, nil} = ExPlain.Users.get_by_id(stub_client(__MODULE__), "usr_unknown")
    end
  end

  describe "get_by_email/2" do
    test "returns user when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"userByEmail" => user_fixture()}})
      end)

      assert {:ok, %User{}} =
               ExPlain.Users.get_by_email(stub_client(__MODULE__), "bob@example.com")
    end
  end

  # ---------------------------------------------------------------------------

  defp user_fixture do
    %{
      "id" => "usr_01",
      "fullName" => "Bob Agent",
      "publicName" => "Bob",
      "email" => "bob@example.com",
      "updatedAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"}
    }
  end
end
