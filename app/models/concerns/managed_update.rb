# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ManagedUpdate
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_update_params, on: :update
  end
  
  private
  def sanitize_update_params
    restore_attributes(["updated_at", :updated_at, "created_at", :created_at])
  end


end