# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Query do
  let(:instance) { Client::Query.new(:some_type, {some: "query"}) }
  it "has a type" do
    expect(instance.type).to eql(:some_type)
  end
  it "has params" do
    expect(instance.params).to eql(some: "query")
  end
  
  describe "#==, #eql?" do
    it "equals an identical record" do
      expect(instance).to eql(Client::Query.new(:some_type, {some: "query"}))
    end
    it "is not equal if type differs" do
      expect(instance).to_not eql(Client::Query.new(:some_other_type, {some: "query"}))
    end
    it "is not equal if params differ" do
      expect(instance).to_not eql(Client::Query.new(:some_type, {some: "query", other: "other"}))
    end
  end
end