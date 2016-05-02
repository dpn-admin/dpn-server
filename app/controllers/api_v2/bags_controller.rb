# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ApiV2::BagsController < ::ApiV1::BagsController

  def create
    if Bag.find_by_uuid(params[:uuid]).present?
      render nothing: true, status: 409 and return
    else
      @bag = Bag.new(create_params)
      @bag.replicating_nodes = params[:replicating_nodes]
      @bag.version_family = params[:version_family]
      if @bag.type == DataBag.to_s
        @bag.rights_bags = params[:rights_bags]
        @bag.interpretive_bags = params[:interpretive_bags]
      end
      if @bag.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end

end
