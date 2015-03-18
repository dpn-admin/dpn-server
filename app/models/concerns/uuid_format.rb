module UUIDFormat
  extend ActiveSupport::Concern

  module ClassMethods
    def make_uuid(field)

      # Override the field=(value) method.
      define_method("#{field}=") do |uuid|
        if uuid.nil?
          write_attribute(field.to_sym, uuid)
        else
          write_attribute(field.to_sym, uuid.delete('-').downcase)
        end
      end

      # Override the field's getter method.
      define_method("#{field}") do
        uuid = read_attribute(field.to_sym)
        # 9th, 14th, 19th and 24th
        if uuid.include?("-") == false
          uuid.insert(8, "-")
          uuid.insert(13, "-")
          uuid.insert(18, "-")
          uuid.insert(23, "-")
        end
        uuid
      end

      # Override the find_by_field(value) class method.
      define_singleton_method("find_by_#{field}") do |uuid|
        if uuid.nil?
          super(uuid)
        else
          super(uuid.delete('-').downcase)
        end
      end

      # Create validations
      validates field.to_sym, format: {
          with: /\A[a-f0-9]{8}[a-f0-9]{4}[a-f0-9]{4}[a-f0-9]{4}[a-f0-9]{12}\Z/,
          message: "must be a UUIDv4 without dashes to save to the db."
        }, on: :save


    end
  end
end