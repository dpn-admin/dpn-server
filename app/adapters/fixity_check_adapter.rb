# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.



RailsViewAdapters::Adapter.define(:fixity_check_adapter) do
  map_date :created_at, :created_at, Time::DATE_FORMATS[:dpn]
  map_date :fixity_at,  :fixity_at,  Time::DATE_FORMATS[:dpn]
  map_simple      :fixity_check_id,   :fixity_check_id
  map_bool        :success,           :success
  map_belongs_to  :bag,               :bag,       sub_method: :uuid
  map_belongs_to  :node,              :node,      sub_method: :namespace
end
