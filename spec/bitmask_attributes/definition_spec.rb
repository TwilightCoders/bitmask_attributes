require("spec_helper")
RSpec.describe(BitmaskAttributes) do
  context("validate_for") do
    context("when missing column") do
      before do
        @column = Class.new do
          attr_reader(:name)
          def initialize(name)
            @name = name
          end
        end
        @model = Class.new do
          attr_reader(:columns)
          def initialize(columns)
            @columns = columns
          end
          def table_exists?
            true
          end
          def self.name
            "Model"
          end
        end
      end
      it("not fail") do
        definition = BitmaskAttributes::Definition.new(:missing_column)
        some_model = @model.new([@column.new(:name)])
        definition.send(:validate_for, some_model)
      end
    end
  end
end
