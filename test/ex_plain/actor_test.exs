defmodule ExPlain.ActorTest do
  use ExUnit.Case, async: true

  alias ExPlain.Actor

  describe "from_map/1" do
    test "returns nil for nil" do
      assert nil == Actor.from_map(nil)
    end

    test "decodes UserActor" do
      assert %Actor{type: :user, user_id: "usr_01"} =
               Actor.from_map(%{"__typename" => "UserActor", "userId" => "usr_01"})
    end

    test "decodes CustomerActor" do
      assert %Actor{type: :customer, customer_id: "c_01"} =
               Actor.from_map(%{"__typename" => "CustomerActor", "customerId" => "c_01"})
    end

    test "decodes SystemActor" do
      assert %Actor{type: :system} = Actor.from_map(%{"__typename" => "SystemActor"})
    end

    test "decodes MachineUserActor" do
      assert %Actor{type: :machine_user, machine_user_id: "mu_01"} =
               Actor.from_map(%{
                 "__typename" => "MachineUserActor",
                 "machineUserId" => "mu_01"
               })
    end

    test "decodes DeletedCustomerActor" do
      assert %Actor{type: :deleted_customer, customer_id: "c_del"} =
               Actor.from_map(%{
                 "__typename" => "DeletedCustomerActor",
                 "customerId" => "c_del"
               })
    end
  end
end
