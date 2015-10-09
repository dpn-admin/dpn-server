# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApiV1
  class MemberAdapter < ::Adapter

    PUBLIC_HASH_KEYS = [
      :uuid,
      :name,
      :email,
      :created_at,
      :updated_at
    ]

    def self.from_model(model)
      internals = {
        uuid: model.uuid,
        name: model.name,
        email: model.email,
        created_at: model.created_at,
        updated_at: model.updated_at
      }

      self.new(internals, {})
    end


    def self.from_public(public_hash)
      internals = {
        uuid: public_hash[:uuid],
        name: public_hash[:name],
        email: public_hash[:email]
      }

      [:created_at, :updated_at].each do |key|
        if public_hash[key].is_a? String
          internals[key] = time_from_string(public_hash[key])
        end
      end

      extras = {}
      (public_hash.keys - PUBLIC_HASH_KEYS).each do |extra_key|
        extras[extra_key] = public_hash[extra_key]
      end

      self.new(internals, extras)
    end


    def to_model_hash
      @internals
    end


    def to_public_hash
      @public_hash ||= {
        uuid: @internals[:uuid],
        name: @internals[:name],
        email: @internals[:email],
        created_at: @internals[:created_at].to_formatted_s(:dpn),
        updated_at: @internals[:updated_at].to_formatted_s(:dpn)
      }
    end


  end
end