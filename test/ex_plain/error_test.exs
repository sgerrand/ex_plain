defmodule ExPlain.ErrorTest do
  use ExUnit.Case, async: true

  alias ExPlain.Error

  describe "new/2" do
    test "builds an error struct" do
      assert %Error{type: :forbidden, message: "Forbidden"} = Error.new(:forbidden, "Forbidden")
    end
  end

  describe "from_mutation_error/1" do
    test "decodes a mutation error with field errors" do
      raw = %{
        "message" => "Email is invalid.",
        "type" => "VALIDATION",
        "code" => "input_validation",
        "fields" => [
          %{"field" => "email", "message" => "Email is invalid.", "type" => "VALIDATION"}
        ]
      }

      assert %Error{
               type: :mutation_error,
               message: "Email is invalid.",
               code: "input_validation",
               fields: [%{field: "email", type: :validation}]
             } = Error.from_mutation_error(raw)
    end

    test "decodes NOT_FOUND field error type" do
      raw = %{
        "message" => "Not found.",
        "type" => "NOT_FOUND",
        "code" => "not_found",
        "fields" => [%{"field" => "id", "message" => "Not found.", "type" => "NOT_FOUND"}]
      }

      assert %Error{fields: [%{type: :not_found}]} = Error.from_mutation_error(raw)
    end

    test "decodes REQUIRED field error type" do
      raw = %{
        "message" => "Required.",
        "type" => "REQUIRED",
        "code" => "required",
        "fields" => [%{"field" => "name", "message" => "Required.", "type" => "REQUIRED"}]
      }

      assert %Error{fields: [%{type: :required}]} = Error.from_mutation_error(raw)
    end
  end
end
