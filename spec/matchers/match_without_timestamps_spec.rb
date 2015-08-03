# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require "rails_helper"

describe "match_without_timestamps" do
  context "when timestamps not present" do
    context "when hashes match" do
      let(:a) { {x: 1, y: 2, z: 3} }
      let(:b) { {x: 1, y: 2, z: 3} }
      it "matches" do
        expect(a).to match_without_timestamps(b)
      end
    end

    context "when hashes don't match" do
      let(:a) { {x: 1, y: 2, z: 3} }
      let(:b) { {x: 1, y: 2, z: 4} }

      it "doesn't match" do
        expect(a).to_not match_without_timestamps(b)
      end

      it "returns a diff" do
        expect {
          expect(a).to match_without_timestamps(b)
        }.to raise_error(/Diff/)
      end
    end
  end

  context "when updated_at present" do
    let(:a) { {x: 1, updated_at: 2, z: 3} }
    let(:b) { {x: 1, updated_at: 5, z: 3} }
    it "matches (ignoring updated_at)" do
      expect(a).to match_without_timestamps(b)
    end
  end

  context "when created_at present" do
    let(:a) { {x: 1, created_at: 2, z: 3} }
    let(:b) { {x: 1, created_at: 5, z: 3} }
    it "matches (ignoring created_at)" do
      expect(a).to match_without_timestamps(b)
    end
  end

  context "when created_at present and other fields don't match" do
    let(:a) { {x: 1, created_at: 2, z: 3} }
    let(:b) { {x: 1, created_at: 5, z: 4} }
    it "doesn't display created_at in the diff" do
      begin
        expect(a).to match_without_timestamps(b)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        expect(e.message).to_not match(/created_at/)
      end

    end
  end

end