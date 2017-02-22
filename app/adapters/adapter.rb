# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Adapter

  # Register a simple one-to-one mapping.
  # @param [Symbol] model_field
  # @param [Symbol] public_field
  def map_simple(model_field, public_field)
    simple_maps << [model_field, public_field]
    model_fields << model_field
    public_fields << public_field
  end


  # Register a one-to-one mapping of a date field.
  # @param [Symbol] model_field
  # @param [Symbol] public_field
  def map_date(model_field, public_field)
    map_from_public public_field do |value|
      {model_field => time_from_public(value)}
    end
    map_to_public model_field do |value|
      # return a datetime in UTC, using an iso8601 format
      {public_field => value.utc.iso8601}
    end
  end

  # Register a one-to-one mapping of a boolean field
  # @param [Symbol] model_field
  # @param [Symbol] public_field
  def map_bool(model_field, public_field)
    map_from_public public_field do |value|
      if value.nil?
        {model_field => nil}
      else
        {model_field => to_bool(value) }
      end
    end

    map_to_public model_field do |value|
      {public_field => value}
    end
  end

  # Register a hidden field.
  # @param [Symbol] model_field
  def hidden_field(model_field)
    model_fields << model_field
  end


  # Register a mapping of a belongs_to association.
  # @param [Symbol] model_field  The field on the model that holds the association,
  #   usually the association's name.
  # @param [Symbol] public_field The public field.
  # @param [Hash] options
  # @option options [Class] :model_class The class of the model, if it cannot
  #   be inferred from the association name.
  # @option options [Symbol] :sub_method The method of the association model
  #   that holds the desired data.  If this isn't provided, it's assumed
  #   to be the same as public_field.
  def map_belongs_to(model_field, public_field, options = {})
    model_class = options[:model_class] || model_field.to_s.classify.constantize
    sub_method = options[:sub_method] || public_field

    unless options[:only] == :to
      map_from_public public_field do |value|
        record = model_class.send(:"find_by_#{sub_method}", value)
        {model_field => record ? record : model_class.new(sub_method => value)}
      end
    end

    unless options[:only] == :from
      map_to_public model_field do |record|
        {public_field => record.send(sub_method)}
      end
    end
  end


  def map_has_many(model_field, public_field, options = {})
    model_class = options[:model_class] || model_field.to_s.classify.constantize
    sub_method = options[:sub_method] || public_field

    unless options[:only] == :to
      map_from_public public_field do |value|
        result = {model_field => model_class.where(sub_method => value)}
        public_field_size = value.respond_to?(:size) ? value.size : 0
        result[model_field].fill(nil, result[model_field].size, public_field_size - result[model_field].size)
        result
      end
    end

    unless options[:only] == :from
      map_to_public model_field do |records|
        {public_field => records.pluck(sub_method.to_sym)}
      end
    end
  end


  # Register a mapping from a model field to the public representation.
  # @param [Symbol] model_field
  # @param [Array<Symbol>] extra_public_fields Used to tell the adapter about
  #   extra public fields created by this mapping.
  # @yield [model_value] Given the value of the model's model_field, return
  #   a hash of key:values pairs to merge into the public representation.
  def map_to_public(model_field, extra_public_fields = [], &block)
    to_maps << [model_field, block]
    model_fields << model_field
    extra_public_fields.each do |field|
      public_fields << field
    end
  end


  # Register a mapping from a public field to the model representation.
  # @param [Symbol] public_field
  # @yield [public_value] Given the value of public representation's
  #   public_field, return a hash of key:value pairs to merge into
  #   the internal model representation.
  def map_from_public(public_field, &block)
    from_maps << [public_field, block]
    public_fields << public_field
  end


  # Create an instance from an ActiveRecord model.
  # @param [ActiveRecord::Base] model
  # @return the adapter
  def from_model(model)
    internals = {}
    model_fields.each do |field|
      internals[field] = model.send(field)
    end
    self.new(internals, {})
  end


  # Create an instance from a public representation.
  # @param [ActionController::Parameters] public
  # @return the adapter
  def from_public(public)
    internals = {}
    simple_maps.each do |model_field, public_field|
      internals[model_field] = public[public_field]
    end

    extras = {}
    (public.keys.map{|k|k.to_sym} - public_fields).each do |extra_key|
      extras[extra_key] = public[extra_key]
    end

    from_maps.each do |public_field, process|
      internals.merge!(process.call(public[public_field]))
    end

    self.new(internals, extras)
  end


  def time_from_public(time)
    if time.is_a? String
      # return Time object, trucated to seconds, e.g.
      # time = "2015-02-25T15:27:40.6Z"
      # Time.iso8601(time).change(:usec => 0)
      # => "2015-02-25T15:27:40.000Z"
      Time.iso8601(time).change(:usec => 0)
    else
      time
    end
  end

  def simple_maps
    @simple_maps ||= []
  end

  def to_maps
    @to_maps ||= []
  end

  def from_maps
    @from_maps ||= []
  end


  def model_fields
    @model_fields ||= []
  end

  def public_fields
    @public_fields ||= []
  end

  private

  def to_bool(value)
    return true if value == true || value =~ (/^(true|t|yes|y|1)$/i)
    return false if value == false || value =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for boolean: \"#{value}\"")
  end


end
