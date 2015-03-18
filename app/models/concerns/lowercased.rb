module Lowercased
  extend ActiveSupport::Concern

  module ClassMethods
    def make_lowercased(field)

      # Override the field=(value) method.
      define_method("#{field}=") do |value|
        if value.nil?
          write_attribute(field.to_sym, value)
        else
          write_attribute(field.to_sym, value.downcase)
        end
      end

      # Override the find_by_field(value) class method.
      define_singleton_method("find_by_#{field}") do |value|
        if value.nil?
          super(value)
        else
          super(value.downcase)
        end
      end

      # Create a validation
      validates field.to_sym, format: { with: /[^A-Z\s]+/, message: "does not allow whitespace or capital letters."}

    end
  end


end