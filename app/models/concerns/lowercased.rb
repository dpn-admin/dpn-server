module Lowercased
  extend ActiveSupport::Concern

  module ClassMethods
    def make_lowercased(field)

      # Override the field=(value) method.
      define_method("#{field}=") do |value|
        write_attribute(field.to_sym, value.downcase)
      end

      # Override the find_by_field(value) class method.
      define_singleton_method("find_by_#{field}") do |value|
        super(value.downcase)
      end

      # Create a validation
      validates field.to_sym, format: { with: /[^A-Z\s]+/, message: "Whitespace and capitals not allowed"}

    end
  end


end