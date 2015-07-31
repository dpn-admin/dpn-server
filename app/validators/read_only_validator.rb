
class ReadOnlyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.send(:"#{attribute}_changed?")
      record.errors[attribute] << "#{attribute} is marked read-only but was changed."
    end
  end
end