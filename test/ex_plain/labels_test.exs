defmodule ExPlain.LabelsTest do
  use ExUnit.Case, async: true

  alias ExPlain.Labels.LabelType

  defp stub_client(stub_name) do
    ExPlain.new(api_key: "test_key", plug: {Req.Test, stub_name})
  end

  describe "Label.from_map/1" do
    test "returns nil for nil" do
      assert nil == ExPlain.Labels.Label.from_map(nil)
    end
  end

  describe "list/2" do
    test "returns paginated label types" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "labelTypes" => %{
              "edges" => [%{"node" => label_type_fixture()}],
              "pageInfo" => page_info_fixture()
            }
          }
        })
      end)

      assert {:ok, %{nodes: [%LabelType{}]}} = ExPlain.Labels.list(stub_client(__MODULE__))
    end
  end

  describe "get_by_id/2" do
    test "returns label type when found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"labelType" => label_type_fixture()}})
      end)

      assert {:ok, %LabelType{id: "lbt_01"}} =
               ExPlain.Labels.get_by_id(stub_client(__MODULE__), "lbt_01")
    end

    test "returns nil when not found" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"data" => %{"labelType" => nil}})
      end)

      assert {:ok, nil} = ExPlain.Labels.get_by_id(stub_client(__MODULE__), "lbt_unknown")
    end
  end

  describe "create/2" do
    test "returns created label type" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "createLabelType" => %{"labelType" => label_type_fixture(), "error" => nil}
          }
        })
      end)

      assert {:ok, %LabelType{}} =
               ExPlain.Labels.create(stub_client(__MODULE__), %{name: "Bug"})
    end
  end

  describe "archive/2" do
    test "returns archived label type" do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "data" => %{
            "archiveLabelType" => %{
              "labelType" => label_type_fixture() |> Map.put("isArchived", true),
              "error" => nil
            }
          }
        })
      end)

      assert {:ok, %LabelType{is_archived: true}} =
               ExPlain.Labels.archive(stub_client(__MODULE__), "lbt_01")
    end
  end

  # ---------------------------------------------------------------------------

  defp label_type_fixture do
    %{
      "id" => "lbt_01",
      "name" => "Bug",
      "icon" => nil,
      "isArchived" => false,
      "archivedAt" => nil,
      "archivedBy" => nil,
      "createdAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "createdBy" => nil,
      "updatedAt" => %{"iso8601" => "2024-01-01T00:00:00Z", "unixTimestamp" => "1704067200"},
      "updatedBy" => nil
    }
  end

  defp page_info_fixture do
    %{
      "hasNextPage" => false,
      "hasPreviousPage" => false,
      "startCursor" => "c_start",
      "endCursor" => "c_end"
    }
  end
end
