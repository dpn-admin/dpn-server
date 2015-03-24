module UUIDFormat
  extend ActiveSupport::Concern

  module ClassMethods
    def make_uuid(field)

      # Override the field=(value) method.
      define_method("#{field}=") do |uuid|
        if uuid
          uuid = uuid.delete('-').downcase
        end
        write_attribute(field.to_sym, uuid)
      end

      # Override the field's getter method.
      define_method("#{field}") do
        _uuid = read_attribute(field.to_sym)
        # 9th, 14th, 19th and 24th
        if _uuid.include?("-") == false
          _uuid.insert(8, "-")
          _uuid.insert(13, "-")
          _uuid.insert(18, "-")
          _uuid.insert(23, "-")
        end
        _uuid
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
          with: /\A[a-f0-9]{8}[a-f0-9]{4}[a-f0-9]{4}[a-f0-9]{4}[a-f0-9]{12}\Z/,
          message: "must be a UUIDv4 without dashes to save to the db."
        }, on: :save


    end
  end
end