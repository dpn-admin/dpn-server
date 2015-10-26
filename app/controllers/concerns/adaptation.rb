# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Adaptation
  extend ActiveSupport::Concern

  module ClassMethods
    def adapt!
      append_before_action :adapt_params
    end
  end

  private
  def adapt_params
    adapter = "#{controller_path.classify}Adapter".constantize
    params.transform_keys! {|key| key.to_sym}
    params.merge!(adapter.from_public(params).to_params_hash) {|key,lhs,rhs| lhs}
  end

end