# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

shared_examples "an unauthorized update" do |key, options, legal_update|
  raise ArgumentError, "Missing required parameters" unless key && legal_update
  unless options
    options = proc {{}}
  end

  before(:each) do
    @request.headers["Content-Type"] = "application/json"
    @existing_record = Fabricate(factory, options.call)
    @put_body = adapter.from_model(@existing_record).to_public_hash
    put :update, legal_update.call(@put_body)
  end

  it_behaves_like "an unauthorized request"
  it "does not update the record" do
    expect(@existing_record.updated_at.to_s).to eql(@existing_record.reload.updated_at.to_s)
  end
end
