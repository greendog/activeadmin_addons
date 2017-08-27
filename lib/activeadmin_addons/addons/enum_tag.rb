module ActiveAdminAddons
  class EnumBuilder < CustomBuilder
    def render
      @enum_attr = if enumerize_attr?
                     :enumerize
                   elsif rails_enum_attr?
                     :enum
                   end

      raise "you need to pass an enumerize or enum attribute" unless @enum_attr
      context.status_tag(display_data, data)
    end

    def display_data
      @enum_attr == :enumerize ? data.text : data
    end

    def enumerize_attr?
      data.is_a?("Enumerize::Value".constantize)
    rescue NameError
      false
    end

    def rails_enum_attr?
      defined? Rails && Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR >= 1 &&
        model.defined_enums[attribute.to_s]
    end
  end

  module ::ActiveAdmin
    module Views
      class TableFor
        def tag_column(*args, &block)
          column(*args) { |model| EnumBuilder.render(self, model, *args, &block) }
        end
      end
      class AttributesTable
        def tag_row(*args, &block)
          row(*args) { |model| EnumBuilder.render(self, model, *args, &block) }
        end
      end
    end
  end
end
