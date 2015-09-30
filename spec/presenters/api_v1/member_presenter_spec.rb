# Copyright (c) 2015 The Regents of the University of shake.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ApiV1::MemberPresenter do
  describe "sanity" do
    it "has a valid factory" do
      expect(Fabricate(:member)).to be_valid
    end

    it "can be built" do
      member = Fabricate(:member)
      expect {
        presenter = ApiV1::MemberPresenter.new(member)
        expect(presenter).to_not be_nil
      }.to_not raise_error
    end
  end

  describe "#to_hash" do
    before(:each) do
      member = Fabricate(:member)
      @presenter = ApiV1::MemberPresenter.new(member)
    end

    before(:all) do
      @uuid_pattern = /\A[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}\Z/
    end

    it "returns a hash" do
      expect(@presenter.to_hash).to be_a(Hash)
    end

    it "returns a uuid" do
      expect(@presenter.to_hash[:uuid]).to match(@uuid_pattern)
    end

    it "returns a name" do
      name = @presenter.to_hash[:name]
      expect(name).to be_a(String)
      expect(name).to_not eql("")
    end

    it "returns an email" do
     email = @presenter.to_hash[:email]
     expect(email).to be_a(String)
     expect(email).to_not eql("")
    end
    
  end
end













