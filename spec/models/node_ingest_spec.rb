# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe NodeIngest do
  before(:each) do
    @node_ingest = Fabricate(:ingest, nodes: Fabricate.times(rand(1..5), :node)).node_ingests.first
  end
  
  describe "#ingest" do
    it "is readonly" do
      expect(@node_ingest.update(ingest: Fabricate(:ingest))).to be false
    end
  end
  
  describe "#node" do
    it "cannot be modified" do
      expect(@node_ingest.update(node: Fabricate(:node))).to be false
    end  
  end
  

end