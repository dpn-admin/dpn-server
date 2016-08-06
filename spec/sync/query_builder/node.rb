# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Sync::QueryBuilder::Node do
  before(:each) do
    @last_success = Time.now
    @query = Sync::Query.new :node, "them"
  end

  let(:query_builder) { Sync::QueryBuilder::Node.new("us", "them") }

  it "builds the correct queries" do
    queries = query_builder.queries(@last_success)
    expect(queries).to contain_exactly(@query)
  end
end