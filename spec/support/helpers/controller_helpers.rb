# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module ControllerHelpers
  def model_class
    described_class.to_s.demodulize.gsub("Controller", "").classify.constantize
  end

  def adapter
    "#{described_class.to_s.gsub("Controller", "").singularize}Adapter".constantize
  end

  def factory
    model_class.to_s.underscore.to_sym
  end
end