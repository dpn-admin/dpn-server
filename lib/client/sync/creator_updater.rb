# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Sync

    # This class abstracts either finding and updating a record,
    # or creating a new record in one operation.
    class CreatorUpdater

      # @param [Class] model_class The model's class.  Generally, this is a subclass
      #   of ActiveRecord::Base.  It must respond to ::find_fields with an array,
      #   either #update! or #update_with_associations!, and
      def initialize(model_class)
        @model_class = model_class
      end


      # Create a new record or update an existing one.
      # @param [Hash] model_hash The hash representation of the updated model.
      def update!(model_hash)
        type = record_type(model_hash)
        record = find_record(type, model_hash) || type.new
        method = record.respond_to?(:update_with_associations!) ? :update_with_associations! : :update!
        record.public_send(method, model_hash)
      end

      private

      # @param [Class] model_class
      # @param [Hash] model_hash
      # @return [Nil, ActiveRecord::Base]
      def find_record(model_class, model_hash)
        model_class.find_by model_hash.slice(*(model_class.find_fields))
      end


      # @param [Hash] model_hash
      # @return [Class]
      def record_type(model_hash)
        model_hash[:type]&.constantize || @model_class
      end


      def type
        @model_class
      end

    end

  end
end

