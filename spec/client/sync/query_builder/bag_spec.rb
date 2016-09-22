# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Sync::QueryBuilder::Bag do
  before(:each) do
    @last_success = Time.now
    @data_query, @rights_query, @interpretive_query = %w(D R I).map do |bag_type|
      Client::Query.new :bag, {
        after: @last_success,
        bag_type: bag_type,
        admin_node: "them"
      }
    end
  end
  
  let(:query_builder) { Client::Sync::QueryBuilder::Bag.new("us", "them") }
  
  it "builds the correct queries" do
    queries = query_builder.queries(@last_success)
    expect(queries).to end_with(@data_query)
    expect(queries).to include(@rights_query, @interpretive_query)
  end
end