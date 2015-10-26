# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ReadOnlyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.send(:"#{attribute}_changed?")
      record.errors[attribute] << "is marked read-only but was changed."
    end
  end
end