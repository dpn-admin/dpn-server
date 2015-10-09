# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class Adapter

  def initialize(internals, extras)
    @internals = internals
    @extras = extras
    @model_hash = nil
    @public_hash = nil
    @params_hash = nil
  end


  def to_params_hash
    @params_hash ||= to_model_hash.merge(@extras.symbolize_keys) {|key,lhs,rhs| lhs}
  end


  def to_json(options = {})
    return self.to_public_hash.to_json(options)
  end

end