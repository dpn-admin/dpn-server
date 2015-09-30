# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module UUIDFormat
  extend ActiveSupport::Concern

  module ClassMethods
    def make_uuid(field)

      # Override the field=(value) method.
      define_method("#{field}=") do |uuid|
        if uuid
          uuid = uuid.delete('-').downcase
        end
        self[field.to_sym] = uuid
      end

      # Override the field's getter method.
      define_method("#{field}") do
        uuid = self[field.to_sym]
        if uuid && uuid.size == 32
          unless uuid.include?("-")
            uuid = uuid.dup # prevents changing the field on the object itself
            uuid.insert(8, "-")   # 9th, 14th, 19th and 24th
            uuid.insert(13, "-")
            uuid.insert(18, "-")
            uuid.insert(23, "-")
          end
        end
        uuid
      end

      # Override the find_by_field(value) class method.
      define_singleton_method("find_by_#{field}") do |value|
        if value
          value = value.delete('-').downcase
        end
        find_by(field.to_sym => value)
      end

      # Override the find_by_field(value)! class method.
      define_singleton_method("find_by_#{field}!") do |value|
        if value
          value = value.delete('-').downcase
        end
        find_by!(field.to_sym => value)
      end

      # Create validations
      validates field.to_sym, format: {
          with: /\A[a-f0-9]{8}\-?[a-f0-9]{4}\-?[a-f0-9]{4}\-?[a-f0-9]{4}\-?[a-f0-9]{12}\Z/,
          message: "Must be a UUIDv4."
        }, on: :save


    end
  end
end