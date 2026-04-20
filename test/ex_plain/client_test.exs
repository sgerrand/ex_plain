defmodule ExPlain.ClientTest do
  use ExUnit.Case, async: true

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "execute/3 HTTP error responses" do
    test "returns forbidden error on 401" do
      Req.Test.stub(__MODULE__, fn conn ->
        Plug.Conn.send_resp(conn, 401, "Unauthorized")
      end)

      assert {:error, %ExPlain.Error{type: :forbidden}} =
               ExPlain.Client.execute(stub_client(__MODULE__), "query { me }")
    end

    test "returns forbidden error on 403" do
      Req.Test.stub(__MODULE__, fn conn ->
        Plug.Conn.send_resp(conn, 403, "Forbidden")
      end)

      assert {:error, %ExPlain.Error{type: :forbidden}} =
               ExPlain.Client.execute(stub_client(__MODULE__), "query { me }")
    end

    test "returns bad_request error on 400 with error message" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "errors" => [%{"message" => "Unknown field 'foo'"}]
        })
        |> Map.put(:status, 400)
      end)

      assert {:error, %ExPlain.Error{type: :bad_request, message: "Unknown field 'foo'"}} =
               ExPlain.Client.execute(stub_client(__MODULE__), "query { foo }")
    end

    test "returns bad_request with fallback message when body has no errors" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{})
        |> Map.put(:status, 400)
      end)

      assert {:error, %ExPlain.Error{type: :bad_request}} =
               ExPlain.Client.execute(stub_client(__MODULE__), "query { foo }")
    end

    test "returns internal_server_error on 500" do
      Req.Test.stub(__MODULE__, fn conn ->
        Plug.Conn.send_resp(conn, 500, "Server Error")
      end)

      assert {:error, %ExPlain.Error{type: :internal_server_error}} =
               ExPlain.Client.execute(stub_client(__MODULE__), "query { me }")
    end

    test "returns graphql_error when response contains errors array" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "errors" => [%{"message" => "Not authorised to access this resource"}]
        })
      end)

      assert {:error,
              %ExPlain.Error{
                type: :graphql_error,
                message: "Not authorised to access this resource"
              }} = ExPlain.Client.execute(stub_client(__MODULE__), "query { me }")
    end
  end

  describe "execute/3 network errors" do
    test "returns unknown error on transport error" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.transport_error(conn, :econnrefused)
      end)

      assert {:error, %ExPlain.Error{type: :unknown}} =
               ExPlain.Client.execute(stub_client(__MODULE__), "query { me }")
    end
  end

  describe "Client.new/2 default base_url" do
    test "builds a client with default extra_req_opts" do
      assert %ExPlain.Client{} = ExPlain.Client.new("key", "http://localhost")
    end
  end

  describe "execute/3 success" do
    test "returns data map on 200" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"me" => %{"id" => "usr_01"}}})
      end)

      assert {:ok, %{"me" => %{"id" => "usr_01"}}} =
               ExPlain.Client.execute(stub_client(__MODULE__), "query { me { id } }")
    end
  end
end
