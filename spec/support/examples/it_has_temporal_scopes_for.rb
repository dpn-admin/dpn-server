# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "it has temporal scopes for" do |field|
  scope_prefix = field.to_s.split("_").first
  before_method = :"#{scope_prefix}_before"
  after_method = :"#{scope_prefix}_after"

  let(:fabricator) { described_class.to_s.underscore.to_sym }

  describe before_method.to_s do
    it "returns only those records with #{field} before time" do
      r1 = Fabricate(fabricator, field => 3.days.ago)
      r2 = Fabricate(fabricator, field => 2.days.ago)
      r3 = Fabricate(fabricator, field => 1.days.ago)
      expect(described_class.public_send(before_method, 30.hours.ago))
        .to include(r1,r2)
        .and exclude(r3)
    end
  end
  describe after_method.to_s do
    it "returns only those records with #{field} after time" do
      r1 = Fabricate(fabricator, field => 3.days.ago)
      r2 = Fabricate(fabricator, field => 2.days.ago)
      r3 = Fabricate(fabricator, field => 1.days.ago)
      expect(described_class.public_send(after_method, 52.hours.ago))
        .to include(r2,r3)
        .and exclude(r1)
    end
  end

end