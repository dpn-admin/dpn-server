# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Lowercased
  extend ActiveSupport::Concern

  module ClassMethods
    def make_lowercased(field)

      # Override the field=(value) method.
      define_method("#{field}=") do |value|
        if value
          value = value.downcase
        end
        write_attribute(field.to_sym, value)
      end

      # Override the find_by_field(value) class method.
      define_singleton_method("find_by_#{field}") do |value|
        if value
          value = value.downcase
        end
        find_by(field.to_sym => value)
      end

      # Override the find_by_field!(value) class method.
      define_singleton_method("find_by_#{field}!") do |value|
        if value
          value = value.downcase
        end
        find_by!(field.to_sym => value)
      end

      # Create a validation
      validates field.to_sym, allow_nil: true,
        format: { with: /[^A-Z\s]+/, message: "does not allow whitespace or capital letters."}

    end
  end


end