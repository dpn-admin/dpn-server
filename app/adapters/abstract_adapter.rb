# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class AbstractAdapter
  extend Adapter

  def initialize(internals, extras)
    @internals = internals
    @extras = extras
    @public_hash = nil
    @params_hash = nil
  end


  def to_params_hash
    @params_hash ||= to_model_hash.merge(@extras.symbolize_keys) {|key,lhs,rhs| lhs}
  end


  def to_json(options = {})
    return self.to_public_hash.to_json(options)
  end


  def to_model_hash
    @internals
  end


  def to_public_hash
    unless @public_hash
      @public_hash = {}
      simple_maps.each do |model_field, public_field|
        @public_hash[public_field] = @internals[model_field]
      end
      to_maps.each do |model_field, process|
        @public_hash.merge!(process.call(@internals[model_field])) do |k,l,r|
          merge_strategy.call(k,l,r)
        end
      end
    end
    @public_hash
  end


  private

  # Define an instance method for each of the class methods
  # we want to access, otherwise we have to prepend
  # "self.class." each time.
  [:simple_maps, :to_maps].each do |method_name|
    define_method(method_name) do
      self.class.send(method_name)
    end
  end

  def merge_strategy
    @merge_strategy ||= Proc.new do |key, lhs, rhs|
      if lhs.respond_to?(:merge) && rhs.respond_to?(:merge)
        lhs.merge(rhs)
      else
        rhs
      end
    end
  end

end