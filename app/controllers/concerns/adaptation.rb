# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Adaptation
  extend ActiveSupport::Concern

  included do
    append_before_action :adapt_params
  end

  private
  def adapt_params
    adapter = "#{controller_path.classify}Adapter".constantize
    params.merge!(adapter.from_public(params).to_params_hash)
  end
end