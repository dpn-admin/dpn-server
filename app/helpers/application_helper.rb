# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module ApplicationHelper
  def assignee
    if action_name == "index"
      :"@#{model_name.underscore.pluralize}"
    else
      :"@#{model_name.underscore}"
    end
  end

  def model_name
    controller_name.classify
  end

  def adapter
    "#{controller_path.classify.gsub("Controller", "")}Adapter".constantize
  end
end
