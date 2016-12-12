# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

#let(:scope_name) { name of the scope under test }
#let(:field_name) { the field the scope operates on }
shared_examples "a boolean filter" do
  fabricator = described_class.to_s.underscore.to_sym
  let!(:r1) { Fabricate(fabricator, field_name => true) }
  let!(:r2) { Fabricate(fabricator, field_name => false) }

  it "passing true returns only true records" do
    expect(described_class.public_send(scope_name.to_sym, true))
      .to include(r1)
      .and exclude(r2)
  end
  it "passing false returns only false records" do
    expect(described_class.public_send(scope_name.to_sym, false))
      .to exclude(r1)
      .and include(r2)
  end
  it "passing '' returns an empty relation" do
    expect(described_class.public_send(scope_name.to_sym, ""))
      .to eq(described_class.all)
  end
  it "passing nil returns an empty relation" do
    expect(described_class.public_send(scope_name.to_sym, nil))
      .to eq(described_class.all)
  end


end