# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Sync::QueryBuilder::FixityCheck do
  before(:each) do
    @last_success = Time.now
    @query = Client::Query.new :fixity_check, {
      after: @last_success,
      node: "them"
    }
  end

  let(:query_builder) { Client::Sync::QueryBuilder::FixityCheck.new("us", "them") }

  it "builds the correct queries" do
    queries = query_builder.queries(@last_success)
    expect(queries).to contain_exactly(@query)
  end
end